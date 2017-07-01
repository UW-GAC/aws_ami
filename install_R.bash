#!/bin/bash
# install R
#   arg1: R version
#   optional arg2: base R (R-3, R-4, etc)
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

R_VERSION=$1
R_BASE=${2:-R-3}
# download R
mkdir /usr/local/src/R
cd /usr/local/src/R
wget --no-check-certificate https://cran.fhcrc.org/src/base/$R-BASE/R-$R_VERSION.tar.gz
tar zxf R-$R_VERSION.tar.gz

# create the R target install
mkdir /usr/local/R-$R_VERSION

# set config vars for building R; config; make
MKL_LIB_PATH=/opt/intel/mkl/lib/intel64
export LD_LIBRARY_PATH=$MKL_LIB_PATH
MKL="-m64 -L${MKL_LIB_PATH} -lmkl_gf_lp64 -lmkl_core -lmkl_sequential -lpthread -lm"
cd /usr/local/src/R/R-$R_VERSION
./configure --enable-R-shlib --enable-threads=posix --prefix=/usr/local/R-3.3.2 --with-blas="$MKL" --enable-memory-profiling
make
make check
make info
make install

# create R links
ln -s /usr/local/R-$R_VERSION/lib/R/bin/R /usr/local/bin/R
ln -s /usr/local/R-$R_VERSION/lib/R/bin/Rscript /usr/local/bin/Rscript

# install RStudio
sudo apt-get install gdebi-core
mkdir /usr/local/src/rstudio
cd /usr/local/src/rstudio
wget https://download2.rstudio.org/rstudio-server-1.0.143-amd64.deb
sudo dpkg -i rstudio-server-1.0.143-amd64.deb
