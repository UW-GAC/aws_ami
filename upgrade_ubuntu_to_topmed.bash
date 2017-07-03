#!/bin/bash
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
PROJ_IP=$2
HOME_IP=$3
ADMIN_IP=$4
TMLIB_PATH=${5:-/projects/resources/gactools/R_packages}
echo ">>> Upgrading Ubuntu to R $R_VERSION"
echo ">>>   Project IP: $PROJ_IP"
echo ">>>   Home IP: $HOME_IP"
echo ">>>   Admin IP: $ADMIN_IP"
# update basic ubuntu
echo ">>> Update Ubuntu packages ..."
./update_ubuntu.bash > update_ubuntu.log 2>&1

echo ">>> Update Ubuntu with hpc packages ..."
./install_ubuntu_hpc.bash > update_ubuntu_hpc.log 2>&1

echo ">>> Installing R $R_VERSION ..."
./install_R.bash $R_VERSION > install_r.log 2>&1
# manually, mount the EFS volumes (the ip address depends on the
#                                  created EFS volumes)
echo ">>> Mounting EFS volumes ..."
if [ ! -d /projects ]; then
    sudo mkdir /projects
fi
if [ ! -d /topmed_home ]; then
    sudo mkdir /topmed_home
fi
if [ ! -d /admin ]; then
    sudo mkdir /admin
fi
if ! sudo mount | grep $PROJ_IP > /dev/null; then
    sudo mount -t nfs4 -o vers=4.1 $PROJ_IP:/ /projects
else
    echo "$PROJ_IP already mounted"
fi
if ! sudo mount | grep $HOME_IP > /dev/null; then
    sudo mount -t nfs4 -o vers=4.1 $HOME_IP:/ /topmed_home
else
    echo "$HOME_IP already mounted"
fi
if ! sudo mount | grep $ADMIN_IP > /dev/null; then
    sudo mount -t nfs4 -o vers=4.1 $ADMIN_IP:/ /admin
else
    echo "$ADMIN_IP already mounted"
fi
# install TOPMed R packages
echo ">>> Installing TOPMed R packages ..."
./install_topmed_ubuntu.bash $PROJ_IP $R_VERSION > install_topmed.log 2>&1

echo ">>> Adding topmed group ..."
# create the topmed group
if ! compgen -g | grep topmed > /dev/null; then
    sudo addgroup topmed
    # update ubuntu account (current login)
    sudo usermod -a -G topmed ubuntu
    sudo usermod -g topmed
fi

# create user account
echo ">>> Creating UW user accounts  ..."
if ! compgen -u | grep levined > /dev/null; then
    sudo adduser --home /topmed_home/levined --ingroup topmed --disabled-password --gecos GECOS levined
fi
if ! compgen -u | grep kuraisa > /dev/null; then
    sudo adduser --home /topmed_home/kuraisa --ingroup topmed --disabled-password --gecos GECOS kuraisa
fi
if ! compgen -u | grep sdmorris > /dev/null; then
    sudo adduser --home /topmed_home/sdmorris --ingroup topmed --disabled-password --gecos GECOS sdmorris
fi
# install RStudio server
echo ">>> Install RStudio server  ..."
# install RStudio
if [ ! -d /usr/local/src/rstudio ]; then
    sudo apt-get install gdebi-core
    mkdir /usr/local/src/rstudio
    cd /usr/local/src/rstudio
    wget https://download2.rstudio.org/rstudio-server-1.0.143-amd64.deb
    sudo dpkg -i rstudio-server-1.0.143-amd64.deb

    # add uw users to rstudio group
    echo ">>> Adding rstudio-server group to UW accounts ..."
    sudo usermod -a -G rstudio-server levined
    sudo usermod -a -G rstudio-server kuraisa
    sudo usermod -a -G rstudio-server sdmorris
    # rstudio users
    echo ">>> Creating RStudio accounts"
    sudo adduser --ingroup rstudio-server --disabled-password --gecos GECOS rstudio1
    sudo adduser --ingroup rstudio-server --disabled-password --gecos GECOS rstudio2
    sudo adduser --ingroup rstudio-server --disabled-password --gecos GECOS rstudio3

    # to add password (for rstudio) create a file
    echo "rstudio1:rstudioserver1" | sudo chpasswd
    echo "rstudio2:rstudioserver2" | sudo chpasswd
    echo "rstudio3:rstudioserver3" | sudo chpasswd
else
    echo "RStudio Server already built"
fi

# install shiny server
