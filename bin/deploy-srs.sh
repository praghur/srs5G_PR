set -ex
SRCDIR=/var/tmp
CFGDIR=/local/repository/etc
SRS_REPO=https://github.com/srsRAN/$SRS_TYPE

if [ -f $SRCDIR/$SRS_TYPE-setup-complete ]; then
    echo "setup already ran; not running again"
    exit 0
fi

#Install srsran_4G
sudo apt update
sudo apt install -y \
        cmake \
        libfftw3-dev \
        libmbedtls-dev \
        libsctp-dev \
        libzmq3-dev

sudo apt install -y \
        build-essential \
        libboost-program-options-dev \
        libconfig++-dev 
cd $SRCDIR
git clone https://github.com/srsran/srsRAN_4G
cd srsRAN_4G
git checkout release_23_04_1
mkdir build
cd build
cmake ../
make -j `nproc`
sudo make install
sudo ldconfig
touch $SRCDIR/installed_srsran_4G-complete

#Install srsran_Project
sudo apt update
sudo apt install -y \
        cmake \
        libfftw3-dev \
        libmbedtls-dev \
        libsctp-dev \
        libzmq3-dev 

sudo apt install -y \
        build-essential \
        libboost-program-options-dev \
        libconfig++-dev 

sudo apt install -y \
        make \
        gcc \
        g++ \
        pkg-config \
        libyaml-cpp-dev \
        libgtest-dev
cd $SRCDIR
git clone https://github.com/srsran/srsRAN_Project
cd srsRAN_Project
git checkout 4ac5300d4927b5199af69e6bc2e55d061fc33652
mkdir build
cd build
cmake ../ -DENABLE_EXPORT=ON -DENABLE_ZEROMQ=ON
make -j `nproc`
sudo make install
sudo ldconfig
touch $SRCDIR/installed_srsran_project-complete

touch $SRCDIR/setup-completed-fully
