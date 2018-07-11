#!/bin/bash
# install dx toolkit
#   arg1: version
#   arg2: install location
DX_BNAME="dx-toolkit"
DX_BINSTALL=/usr/local
DX_VERSION=${1:-v0.255.0}
DX_INSTALL=${2:-$DX_BINSTALL/$DX_BNAME}
DX_FNAME=$DX_BNAME"-"$DX_VERSION
DX_SRC=/usr/local/src/dxtoolkit/$DX_FNAME
# check if version has been installed
if [ ! -d $DX_INSTALL ]; then
    echo "Updating required packages ..."
    sudo apt-get update && sudo apt-get install -y \
       make \
       python-setuptools \
       python-pip \
       python-virtualenv \
       python-dev \
       gcc \
       g++ \
       cmake \
       libboost-all-dev \
       libcurl4-openssl-dev \
       zlib1g-dev \
       libbz2-dev \
       flex \
       bison \
       openssl \
       libssl-dev \
       autoconf
fi

# check if src is there (if so assumed installed)
if [ ! -d $DX_SRC ]; then
    sudo mkdir -p $DX_SRC
    cd $DX_SRC
    echo "Installing $DX_FNAME ..."
    # if older version is there, remove it
    if [ -d $DX_INSTALL ]; then
        sudo rm -r $DX_INSTALL
    fi
    # get the tar and unpack it
    echo "Getting tar file and extract to $DX_INSTALL ..."
    sudo wget https://wiki.dnanexus.com/images/files/$DX_FNAME-source.tar.gz
    sudo tar -xf $DX_FNAME-source.tar.gz
    # mv to /usr/local
    sudo mv $DX_BNAME $DX_BINSTALL
    cd $DX_INSTALL
    echo "making dx-toolkit ..."
    sudo make
    echo "Installing $DX_FNAME is complete; users must 'source /usr/local/dx-toolkit/environment'"
else
    echo "$DX_FNAME is already installed"
fi
