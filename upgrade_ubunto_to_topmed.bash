#!/bin/sh
# upgrade a base ubuntu to have the following:
#1. Ubuntu server with appropriate security and ssh access
#2. Ubuntu packages supporting:
#    a. Developers (e.g., gcc)
#    b. R and various R packages
#    c. HPC (e.g., hdf5, openmpi)
#3. Intel's MKL
#4. Base R
#5. TOPMed Specific Support
#    a. EFS volumes for projects, home base directory for users (not for ubuntu user)
#    b. TOPMed analysis packages (via bioconductor)
#    c. Miscellaneous R packages (e.g., rmarkdown)
#    d. UW analysis_pipeline
#6. User accounts in topmed group and having home directories on EFS
#7. Optional RStudio server
#8. Optional Shiny server
#
# arg1: R version
# arg2: ip address of /projects
# arg3: ip address of /topmed_home
# arg4: ip address of /admin
# opt arg4: path of topmed r packages in /projects
if [ "$#" -lt 4 ]; then
    echo "ERROR: At least 4 args required: R_version, Proj_ip, Home_ip, and Admin_ip"
    exit 1
fi

R_VERSION=$1
PROJ_IP=$2
HOME_IP=$3
ADMIN_IP=$4
TMLIB_PATH=${5:-/projects/resources/gactools/R_packages}
# update basic ubuntu
./update_ubuntu.bash
./install_ubuntu_hpc.bash
./install_R.bash $R_VERSION
# manually, mount the EFS volumes (the ip address depends on the
#                                  created EFS volumes)
sudo mkdir /projects
sudo mkdir /topmed_home
sudo mkdir /admin
sudo mount -t nfs4 -o vers=4.1 $PROJ_IP:/ /projects
sudo mount -t nfs4 -o vers=4.1 $HOME_IP:/ /topmed_home
sudo mount -t nfs4 -o vers=4.1 $ADMIN_IP:/ /admin
# install TOPMed R packages
./install_topmed_ubuntu.bash $PROJ_IP $R_VERSION
# create the topmed group
sudo addgroup topmed
# update ubuntu account (current login)
sudo usermod -a -G topmed ubuntu
sudo usermod -g topmed

# create user account
sudo adduser --home /topmed_home/levined --ingroup topmed --disabled-password levined
sudo adduser --home /topmed_home/kuraisa --ingroup topmed --disabled-password kuraisa
sudo adduser --home /topmed_home/sdmorris --ingroup topmed --disabled-password sdmorris

# install RStudio server
cd /usr/local/src
sudo mkdir rstudio-server
sudo apt-get install gdebi-core
wget https://download2.rstudio.org/rstudio-server-1.0.143-amd64.deb
sudo dpkg -i  rstudio-server-1.0.143-amd64.deb

# add uw users to rstudio group
sudo usermod -a -G rstudio-server levined
sudo usermod -a -G rstudio-server kuraisa
sudo usermod -a -G rstudio-server sdmorris
# rstudio users
sudo adduser --ingroup rstudio-server --disabled-password rstudio1
sudo adduser --ingroup rstudio-server --disabled-password rstudio2
sudo adduser --ingroup rstudio-server --disabled-password rstudio3

# to add password (for rstudio) create a file
echo "rstudio1:rstudioserver1" | sudo chpasswd
echo "rstudio2:rstudioserver2" | sudo chpasswd
echo "rstudio3:rstudioserver3" | sudo chpasswd

# install shiny server
