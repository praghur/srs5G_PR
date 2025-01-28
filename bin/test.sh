sudo ip netns exec ue1 ip route add 10.45.2.10 via 10.45.0.1
sudo ip netns exec ue1 traceroute -U -f 2 -m 2 -p 33435 10.45.2.10

sudo ip netns exec ue2 ip route add 10.45.1.10 via 10.45.0.1
sudo ip netns exec ue2 traceroute -U -f 2 -m 2 -p 33435 10.45.1.10

sudo tshark -i ogstun -T fields -e frame.time_epoch -e ip.src -e ip.dst -e ip.id -e udp.srcport -e udp.dstport -E header=y -E separator=, -E quote=d > cn_results.csv

sudo tcpdump -i ogstun -w ogstun_capture.pcap


