import os

import geni.portal as portal
import geni.rspec.pg as rspec
import geni.rspec.igext as IG

tourDescription = """

## srsRAN 5G with Open5GS and Simulated RF

This profile instantiates a single-node experiment for running and end to end 5G
network using srsRAN 22.04 and Open5GS with IQ samples passed via ZMQ between
the gNodeB and the UE. It requires a single Dell d430 compute node.

"""
tourInstructions = """

Startup scripts will still be running when your experiment becomes ready.
Watch the "Startup" column on the "List View" tab for your experiment and wait
until all of the compute nodes show "Finished" before proceeding.

After all startup scripts have finished...

In an SSH session on `node`:

```
# create a network namespace for the UE
sudo ip netns add ue1

# start tailing the Open5GS AMF log
tail -f /var/log/open5gs/amf.log
```

In a second session on `node`:

```
# start the gNodeB
sudo srsenb
```

The AMF should show a connection from the gNodeB via the N2 interface.

In a third session on `node`:

```
# start the UE
sudo srsue
```

The UE should attach to the network with the AMF log and gNodeB process
indicating as much.

At this point, you should be able to pass traffic across the network via the
previously created namespace in yet another session on the same node:

```
# start pinging the Open5GS data network
sudo ip netns exec ue1 ping 10.45.0.1
```

Note: when ZMQ is used by srsRAN to pass IQ samples, if you restart of the
`srsenb` or `srsue` processes, you must restart the other.

"""


BIN_PATH = "/local/repository/bin"
ETC_PATH = "/local/repository/etc"
SRS_DEPLOY_SCRIPT = os.path.join(BIN_PATH, "deploy-srs.sh")
OPEN5GS_DEPLOY_SCRIPT = os.path.join(BIN_PATH, "deploy-open5gs.sh")
UBUNTU_IMG = "urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU18-64-STD"
DEFAULT_SRS_HASH = "release_22_04"

pc = portal.Context()
request = pc.makeRequestRSpec()

node = request.RawPC("node")
node.hardware_type = "d430"
node.disk_image = UBUNTU_IMG

cmd = "{} {}".format(SRS_DEPLOY_SCRIPT, DEFAULT_SRS_HASH)
node.addService(rspec.Execute(shell="bash", command=cmd))
node.addService(rspec.Execute(shell="bash", command=OPEN5GS_DEPLOY_SCRIPT))

tour = IG.Tour()
tour.Description(IG.Tour.MARKDOWN, tourDescription)
tour.Instructions(IG.Tour.MARKDOWN, tourInstructions)
request.addTour(tour)

pc.printRequestRSpec(request)
