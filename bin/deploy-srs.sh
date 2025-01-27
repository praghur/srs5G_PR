set -ex
COMMIT_HASH=$1
SRS_TYPE=$2
BINDIR=`dirname $0`
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
touch $SRCDIR/$SRS_TYPE-installed_srsran_4G-complete

#Install srsran_Project
sudo apt update
sudo apt install -y \
        cmake \
        libfftw3-dev \
        libmbedtls-dev \
        libsctp-dev \
        libzmq3-dev \
        build-essential \
        libboost-program-options-dev \
        libconfig++-dev \
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
touch $SRCDIR/$SRS_TYPE-installed_srsran_project-complete

install_srsran_common () {
    sudo apt update
    sudo apt install -y \
        cmake \
        libfftw3-dev \
        libmbedtls-dev \
        libsctp-dev \
        libzmq3-dev \
        build-essential \
        libboost-program-options-dev \
        libconfig++-dev \
    touch $SRCDIR/$SRS_TYPE-install_srsran_common-complete
}

clone_build_install () {
    cd $SRCDIR
    git clone $SRS_REPO #Choose https://github.com/srsran/srsRAN_4G OR https://github.com/srsran/srsRAN_Project
    cd $SRS_TYPE
    git checkout $COMMIT_HASH  #Choose "srsRAN_4G": "release_23_04_1" OR "srsRAN_Project": "4ac5300d4927b5199af69e6bc2e55d061fc33652"
    mkdir build
    cd build
    if [ "$SRS_TYPE" = "srsRAN_Project" ]; then
        cmake ../ -DENABLE_EXPORT=ON -DENABLE_ZEROMQ=ON
    else
        cmake ../
    fi
    make -j `nproc`
    sudo make install
    sudo ldconfig
    touch $SRCDIR/$SRS_TYPE-clone_build_install-complete
}

install_srsran_4g () {
    install_srsran_common
    sudo apt install -y \
        build-essential \
        libboost-program-options-dev \
        libconfig++-dev \

    clone_build_install
    sudo srsran_install_configs.sh service
    sudo cp /local/repository/etc/srsran/* /etc/srsran/
    touch $SRCDIR/$SRS_TYPE-install_srsran_4g-complete
}

install_srsran_project () {
    install_srsran_common
    sudo apt install -y \
        make \
        gcc \
        g++ \
        pkg-config \
        libyaml-cpp-dev \
        libgtest-dev

    clone_build_install
    touch $SRCDIR/$SRS_TYPE-install_srsran_project-complete
}

touch $SRCDIR/$SRS_TYPE-setup-completed-fully
