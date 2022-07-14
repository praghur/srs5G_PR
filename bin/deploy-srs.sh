set -ex
COMMIT_HASH=$1
BINDIR=`dirname $0`
source $BINDIR/common.sh

if [ -f $SRCDIR/srs-setup-complete ]; then
    echo "setup already ran; not running again"
    exit 0
fi

sudo apt update
sudo apt install -y build-essential \
    cmake \
    libfftw3-dev \
    libmbedtls-dev \
    libboost-program-options-dev \
    libconfig++-dev \
    libsctp-dev \
    libzmq3-dev

cd $SRCDIR
git clone $SRS_REPO srsran
cd srsran
git checkout $COMMIT_HASH
mkdir build
cd build
cmake ../
make -j `nproc`
sudo make install
sudo ldconfig
sudo srsran_install_configs.sh service
sudo cp /local/repository/etc/srsran/* /etc/srsran/

touch $SRCDIR/srs-setup-complete
