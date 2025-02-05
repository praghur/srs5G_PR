sudo ip netns exec ue1 ip route add 10.45.2.10 via 10.45.0.1
sudo ip netns exec ue1 traceroute -U -f 2 -m 2 -p 33435 10.45.2.10

sudo ip netns exec ue2 ip route add 10.45.1.10 via 10.45.0.1
sudo ip netns exec ue2 traceroute -U -f 2 -m 2 -p 33435 10.45.1.10

sudo tshark -i ogstun -T fields -e frame.time_epoch -e ip.src -e ip.dst -e ip.id -e udp.srcport -e udp.dstport -E header=y -E separator=, -E quote=d > cn_results.csv
sudo tcpdump -i ogstun -w ogstun_capture.pcap

sudo ip netns exec ue1 tshark -i tun_srsue -T fields -e frame.time_epoch -e ip.src -e ip.dst -e ip.id -e udp.srcport -e udp.dstport -E header=y -E separator=, -E quote=d > ue1_results.csv
sudo ip netns exec ue1 tcpdump -i tun_srsue -w ue1_capture.pcap

sudo ip netns exec ue2 tshark -i tun_srsue -T fields -e frame.time_epoch -e ip.src -e ip.dst -e ip.id -e udp.srcport -e udp.dstport -E header=y -E separator=, -E quote=d > ue2_results.csv
sudo ip netns exec ue2 tcpdump -i tun_srsue -w ue2_capture.pcap


#Save results from CN
scp praghur@pc721.emulab.net:cn_results.csv /home/ubuntu/
scp praghur@pc816.emulab.net:ogstun_capture.pcap /home/ubuntu/

#Save results from UE1
scp praghur@pc05-fort.emulab.net:ue1_results.csv /home/ubuntu/
scp praghur@pc05-fort.emulab.net:ue1_capture.pcap /home/ubuntu/
scp praghur@pc05-fort.emulab.net:/tmp/gnb1_mac.pcap /home/ubuntu/
scp praghur@pc05-fort.emulab.net:/tmp/gnb1_ngap.pcap /home/ubuntu/

#Save results from UE2
scp praghur@pc11-fort.emulab.net:ue2_results.csv /home/ubuntu/
scp praghur@pc11-fort.emulab.net:ue2_capture.pcap /home/ubuntu/
scp praghur@pc11-fort.emulab.net:/tmp/gnb2_mac.pcap /home/ubuntu/
scp praghur@pc11-fort.emulab.net:/tmp/gnb2_ngap.pcap /home/ubuntu/
