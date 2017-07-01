#!/bin/sh
# install hdf5, openmpi, etc
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
sudo chown -R ubuntu /usr/local
mkdir /usr/local/src/mkl
cp ./l_mkl_2017.2.174.tgz /usr/local/src/mkl
echo "\n\n*** building mkl ... ***\n\n"
cd /usr/local/src/mkl
tar -xzvf l_mkl_2017.2.174.tgz
cd /usr/local/src/mkl/l_mkl_2017.2.174
sed 's/ACCEPT_EULA=decline/ACCEPT_EULA=accept/g' silent.cfg > silent_build.cfg
sudo ./install.sh --silent ./silent_build.cfg

echo "/opt/intel/mkl/lib/intel64" > mkl.conf
sudo cp ./mkl.conf /etc/ld.so.conf.d/mkl_intel64.conf
sudo ldconfig
