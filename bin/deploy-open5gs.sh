#!/bin/bash
set -ex
BINDIR=`dirname $0`
source $BINDIR/common.sh

sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE

if [ -f $SRCDIR/open5gs-setup-complete ]; then
    echo "setup already ran; not running again"
    exit 0
fi

sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:open5gs/latest
sudo add-apt-repository -y ppa:wireshark-dev/stable
echo "wireshark-common wireshark-common/install-setuid boolean false" | sudo debconf-set-selections
sudo apt update
sudo apt-get install gnupg
curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
    sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | \
    sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt update
sudo apt install -y \
    mongodb-org \
    mongodb-mongosh \
    iperf3 \
    tshark \
    wireshark

sudo systemctl start mongod
sudo systemctl enable mongod
sudo apt install -y open5gs
sudo cp /local/repository/etc/open5gs/* /etc/open5gs/

sudo systemctl restart open5gs-mmed
sudo systemctl restart open5gs-sgwcd
sudo systemctl restart open5gs-smfd
sudo systemctl restart open5gs-amfd
sudo systemctl restart open5gs-sgwud
sudo systemctl restart open5gs-upfd
sudo systemctl restart open5gs-hssd
sudo systemctl restart open5gs-pcrfd
sudo systemctl restart open5gs-nrfd
sudo systemctl restart open5gs-ausfd
sudo systemctl restart open5gs-udmd
sudo systemctl restart open5gs-pcfd
sudo systemctl restart open5gs-nssfd
sudo systemctl restart open5gs-bsfd
sudo systemctl restart open5gs-udrd

cd $SRCDIR
wget https://raw.githubusercontent.com/open5gs/open5gs/main/misc/db/open5gs-dbctl
chmod +x open5gs-dbctl
##For UE1 connecting with gNB1
./open5gs-dbctl add_ue_with_apn 999700123456789 00112233445566778899aabbccddeeff 63BFA50EE6523365FF14C1F45F88737D internet  # IMSI,K,OPC
./open5gs-dbctl type 999700123456789 1   # APN type IPV4
./open5gs-dbctl static_ip 999700123456789 10.45.1.10

##For UE2 connecting with gNB2
./open5gs-dbctl add_ue_with_apn 999700123456790 00112233445566778899aabbccddeeff 63BFA50EE6523365FF14C1F45F88737D internet  # IMSI,K,OPC
./open5gs-dbctl type 999700123456790 1  # APN type IPV4
./open5gs-dbctl static_ip 999700123456790 10.45.2.10

#Install Web UI for UE DBCTL
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

# Create deb repository
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

# Run Update and Install
sudo apt update
sudo apt install nodejs -y
curl -fsSL https://open5gs.org/open5gs/assets/webui/install | sudo -E bash -

touch $SRCDIR/open5gs-setup-complete
