# Introduction
This repository contains scripts and descriptions creating custom AWS AMIs with the following software:
- Ubuntu
- R
- RStudio server
- TOPMed R packages
- Analysis Pipeline

Additionally the scripts configure the custom AMI to include the following:
- User accounts for UW researchers
- User accounts for RStudio users
- Mounted EFS volumes containing project data, home directories, and admin folders

To create the AMIs, the following preliminary steps are performed:
- EFS volumes are created (one time)
- Creating appropriate security group
- If necessary, creating a specific VPC
- Creating SSH key pair(s)

After the preliminary steps are done, the following steps are done in creating a custom AMI:
- A base Ubuntu AMI is launched
- An upgrading script is executed
- A new AMI of the upgraded AMI is created (because the upgraded AMI is not saved when the image is terminated)

# EFS volumes
Three EFS volumes are created via AWS console with the intentions of containing the following data respectively:
- TOPMed project data (e.g., Freeze 3a)
- Administrative data helpful for managing AWS environments
- Directories containing UW user accounts home directories

The three EFS volumes are created once (for each AWS region) and are shared by multiple launched EC2 instances and are considered volumes with shared, persistent data.

# Custom AMI Attributes
The desired Ubuntu attributes  include the following:
- Developer support (e.g., gcc)
- Packages that support building R and R packages
- HPC packages such as HDF5, MKL, and openmpi
- UW user accounts on Ubuntu have their home directories on an EFS volume so they can be persisted and shared

R is built with the following support:
- MKL and LAPACK
- X11
- Cairo and Pango
- PNG
- Other infrastructure to support various R packages

RStudio server is basically installed as a standard installation.

TOPmed packages are installed as described in UW-GAC githb.  Installation is based on Bioconductor and github repositories.  The packages are installed on EFS project volume and can be shared by multiple launched EC2 instances provided the instances are running the correct version of R.

Analysis pipeline is installed from github supporting linux SGE clusters, AWS cfnclusters, and AWS batch services.

# Creating Custom AMIs
The specific steps (not including the preliminary steps described above) of creating a desired custom AMI involves performing the following:
1. Launch an instance from aws console ec2/instances with the following attributes
    - Ubuntu Server 16.04
    - t2.large instance
    - vpc network associated with the EFS volumes, security groups, etc
    - 30GB storage on the root device
    - the desired seurity group and SSH key pair
2. Log into the launched instance and do the following:
    - Install git
        - `sudo apt-get update && sudo apt-get install -y git`
    - Create the folder _**update__scripts**_
    - cd to _**update__scripts**_
    - Clone the github <i>**aws_ami**</i> repository containing the various scripts
        - `git clone --depth 1 https://github.com/UW-GAC/aws_ami`
    - cd to _**aws__ami**_
    - **MKL is required for this upgrade and a particular version is required.**   Since MKL can only be downloaded from Intel interactively, you should copy <i>**l_mkl_2017.2.174.tgz**</i> to this current directory _**aws__ami**_.  It is suggest to scp <i>**l_mkl_2017.2.174.tgz**</i> to the _**aws__ami**_ folder.
    - Upgrade the AMI by executing the script <i>**upgrade_ubuntu_to_topmed**</i> which takes the following required positional arguments:
        - _**R version**_
        - _**IP address of project data EFS volume**_
        - _**IP address of home directories EFS volume**_
        - _**IP address of admin folder EFS volume**_
    - An optional argument, in the fifth position, can be specified to identify the root folder of TOPMed's R package library; the default is: **/projects/resources/gactools/R_packages**


 # Examples
 ```bash
# upgrade an ami on the tm-workshop account
./upgrade_ubuntu_to_topmed.bash 3.3.2 172.255.39.161 172.255.40.179 172.255.41.187

# upgrade an amni on the topmeddcc account
./upgrade_ubuntu_to_topmed.bash 3.3.2 172.255.44.97 172.255.36.89 172.255.40.251
 ```
# Notes
1. If there is an error (either in the script or the configuration), re-execute the script after fixing the error.
2.  After the uprade has completed, using aws console a new image can be created to preserve the upgrade changes.
