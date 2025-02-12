import os 

import geni.portal as portal
import geni.rspec.pg as rspec
import geni.rspec.igext as IG

tourDescription = """

### srsRAN 5G with Open5GS and Simulated RF

This profile instantiates a single-node experiment for running and end to end 5G
network using srsRAN_Project 23.5 (gNodeB), srsRAN_4G (UE), and Open5GS with IQ
samples passed via ZMQ between the gNodeB and the UE. It requires a single Dell
d430 compute node.

"""
tourInstructions = """

Startup scripts will still be running when your experiment becomes ready.
Watch the "Startup" column on the "List View" tab for your experiment and wait
until all of the compute nodes show "Finished" before proceeding.

Note: You will be opening several SSH sessions on a single node. Using a
terminal multiplexing solution like `screen` or `tmux`, both of which are
installed on the image for this profile, is recommended.

After all startup scripts have finished...

In an SSH session on `node`:

```
# create a network namespace for the UE -- Node 1
sudo ip netns add ue1

# create a network namespace for the UE -- Node 2
sudo ip netns add ue2

# start tailing the Open5GS AMF log
tail -f /var/log/open5gs/amf.log
```

In a second session:

```
# use tshark to monitor 5G core network function traffic
sudo tshark -i lo \
  -f "not arp and not port 53 and not host archive.ubuntu.com and not host security.ubuntu.com and not tcp" \
  -Y "s1ap || gtpv2 || pfcp || diameter || gtp || ngap || http2.data.data || http2.headers"
```

In a third session:

```
# start the gNodeB -- Node 1
sudo gnb -c /local/repository/etc/srsran/gnb1.conf
```
# start the gNodeB -- Node 2
sudo gnb -c /local/repository/etc/srsran/gnb2.conf

```

The AMF should show a connection from the gNodeB via the N2 interface and
`tshark` will show NG setup/response messages.

In a forth session:

```
# start the UE -- Node 1
sudo srsue /local/repository/etc/srsran/ue1.conf
```

```
# start the UE -- Node 2
sudo srsue /local/repository/etc/srsran/ue2.conf
```

As the UE attaches to the network, the AMF log and gNodeB process will show
progress and you will see NGAP/NAS traffic in the output from `tshark` as a PDU
session for the UE is eventually established.

At this point, you should be able to pass traffic across the network via the
previously created namespace in yet another session on the same node:

```
# start pinging the Open5GS data network
sudo ip netns exec ue1 ping 10.45.0.1
```

You can also use `iperf3` to generate traffic. E.g., for downlink, in one session:

```
# start iperf3 server for UE
sudo ip netns exec ue1 iperf3 -s
```

And in another:

```
# start iperf3 client for CN data network
sudo iperf3 -c {ip of UE (indicated in srsue stdout)}
```

Note: When ZMQ is used by srsRAN to pass IQ samples, if you restart either of the
`gnb` or `srsue` processes, you must restart the other as well.

You can find more information about the open source 5G software used in this profile at:

https://open5gs.org
https://github.com/srsran/srsRAN
"""


BIN_PATH = "/local/repository/bin"
ETC_PATH = "/local/repository/etc"
SRS_DEPLOY_SCRIPT = os.path.join(BIN_PATH, "deploy-srs.sh")
OPEN5GS_DEPLOY_SCRIPT = os.path.join(BIN_PATH, "deploy-open5gs.sh")
UBUNTU_IMG = "urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU22-64-STD"
DEFAULT_SRS_HASHES = {
    "srsRAN_Project": "release_24_10_1",
}

pc = portal.Context()
node_types = [
    ("d430", "Emulab, d430"),
    ("d740", "Emulab, d740"),
]

pc.defineParameter(
    name="sdr_nodetype",
    description="Type of compute node to used with the SDRs.",
    typ=portal.ParameterType.STRING,
    defaultValue=node_types[1],
    legalValues=node_types,
)

pc.defineParameter(
    name="cn_nodetype",
    description="Type of compute node to use for CN node.",
    typ=portal.ParameterType.STRING,
    defaultValue=node_types[0],
    legalValues=node_types,
)

params = pc.bindParameters()
pc.verifyParameters()
request = pc.makeRequestRSpec()

core = request.RawPC("core")
core.hardware_type = params.cn_nodetype
core.disk_image = UBUNTU_IMG
iface1 = core.addInterface("cn-if")
iface1.addAddress(rspec.IPv4Address("192.168.1.1", "255.255.255.0"))
core.addService(rspec.Execute(shell="bash", command=OPEN5GS_DEPLOY_SCRIPT))

node1 = request.RawPC("node1")
node1.hardware_type = params.sdr_nodetype
node1.disk_image = UBUNTU_IMG
iface2 = node1.addInterface("eth1")
iface2.addAddress(rspec.IPv4Address("192.168.1.22", "255.255.255.0"))

node2 = request.RawPC("node2")
node2.hardware_type = params.sdr_nodetype
node2.disk_image = UBUNTU_IMG
iface3 = node2.addInterface("eth1")
iface3.addAddress(rspec.IPv4Address("192.168.1.33", "255.255.255.0"))


for srs_type, type_hash in DEFAULT_SRS_HASHES.items():
    cmd = "{} '{}' {}".format(SRS_DEPLOY_SCRIPT, type_hash, srs_type)
    node1.addService(rspec.Execute(shell="bash", command=cmd))
    node2.addService(rspec.Execute(shell="bash", command=cmd))

# Create two separate LAN links
link1 = request.LAN("lan1")

# Add interfaces to each LAN link
link1.addInterface(iface1)
link1.addInterface(iface2)
link1.addInterface(iface3)

link1.link_multiplexing = True
link1.vlan_tagging = True
link1.best_effort = True

tour = IG.Tour()
tour.Description(IG.Tour.MARKDOWN, tourDescription)
tour.Instructions(IG.Tour.MARKDOWN, tourInstructions)
request.addTour(tour)

pc.printRequestRSpec(request)
