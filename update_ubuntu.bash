#!/bin/sh
# build packages on ubuntu needed for R et al
sudo apt-get update && sudo apt-get install -y \
  build-essential \
  python-dev \
  git \
  nodejs-legacy \
  npm \
  gnome-tweak-tool \
  openjdk-8-jdk \
  python-pip \
  python-virtualenv \
  python-numpy \
  python-matplotlib \
  wget \
  cpio \
  iputils-ping \
  texinfo \
  gfortran \
  libreadline6 \
  libreadline6-dev \
  bzip2 \
  libbz2-dev \
  vim \
  lzma \
  liblzma-dev \
  libpcre3-dev \
  libcurl4-gnutls-dev \
  default-jre \
  default-jdk \
  nfs-common \
  libpng12-dev \
  libcairo2-dev \
  libnetcdf-dev \
  libxml2-dev \
  libpango1.0-dev \
  pandoc \
  build-essential \
  checkinstall \
  libncurses-dev
