#!/bin/bash
# install hdf5, openmpi, etc
f () {
    errcode=$? # save the exit code as the first thing done in the trap function
    echo "error $errorcode"
    echo "the command executing at the time of the error was"
    echo "$BASH_COMMAND"
    echo "on line ${BASH_LINENO[0]}"
    # do some error handling, cleanup, logging, notification
    # $BASH_COMMAND contains the command that was being executed at the time of the trap
    # ${BASH_LINENO[0]} contains the line number in the script of that command
    # exit the script or return to try again, etc.
    exit $errcode  # or use some other value or do return instead
}
trap f ERR

sudo apt-get update && sudo apt-get install -y \
  mpich \
  h5utils \
  hdf5-helpers \
  hdf5-tools \
  libhdf5-10 \
  libhdf5-cpp-11 \
  libhdf5-dev \
  libhdf5-doc \
  libopenmpi-dev \
  libopenmpi1.10 \
  openmpi-doc

# mkl
if [ ! -f /etc/ld.so.conf.d/mkl_intel64.conf ]; then
    sudo chown -R ubuntu /usr/local
    if [ ! -d /usr/local/src/mkl ]; then
       mkdir /usr/local/src/mkl
    fi
    if [ ! -f /usr/local/src/mkl/l_mkl_2017.2.174.tgz ]; then
       cp ./l_mkl_2017.2.174.tgz /usr/local/src/mkl
    fi
    echo ">>> building mkl ... "
    cd /usr/local/src/mkl
    if [ ! -d l_mkl_2017.2.174 ]; then
       tar -xzvf l_mkl_2017.2.174.tgz
    fi

    cd /usr/local/src/mkl/l_mkl_2017.2.174
    sed 's/ACCEPT_EULA=decline/ACCEPT_EULA=accept/g' silent.cfg > silent_build.cfg
    sudo ./install.sh --silent ./silent_build.cfg

    echo "/opt/intel/mkl/lib/intel64" > mkl.conf
    sudo cp ./mkl.conf /etc/ld.so.conf.d/mkl_intel64.conf
    sudo ldconfig
else
    echo "mkl already built"
fi
