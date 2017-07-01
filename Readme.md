Here are the attributes of an AMI supporting TOPMed at UW:

>     1. Ubuntu server with appropriate security and ssh access
>     2. Ubuntu packages supporting:
>         a. Developers (e.g., gcc)
>         b. R and various R packages
>         c. HPC (e.g., hdf5, openmpi)
>     3. Intel's MKL
>     4. Base R
>     5. TOPMed Specific Support
>         a. EFS volumes for projects, home base directory for users (not for ubuntu user)
>         b. TOPMed analysis packages (via bioconductor)
>         c. Miscellaneous R packages (e.g., rmarkdown)
>         d. UW analysis_pipeline
>     6. User accounts in topmed group and having home directories on EFS
>     6. Optional RStudio server
>     7. Optional Shiny server

Three EFS volumes for TOPMed need to be created:

>     1. topmed_projects
>     2. topmed_home
>     3. topmed_admin

Creating a desired AMI with the above attributes involves the following steps:

>     1. From aws console (or cli) create a desired security group (see security group
>        topmed_cluster_dev) and a desired ssh key pair
>     2. Optionally from aws console, create a VPC network (see vpc topmed)
>     3. Launch an instance from aws console ec2/instances with the following attributes:
>         a. Ubuntu Server 16.04
>         b. t2.large instance
>         c. select the desired network/subnetwork (that matches the EFS volumes)
>         d. 30GB storage (minimum of 15GB depending on number of users and
>            amount of data on the root device)
>         e. Add an appropriate name
>         f. select the desired security group
>         g. select the desired key pair to be associated with the launched instance

ssh into the Ubuntu Server (ubuntu) and do the following (for R 3.3.2):

>     1. install git
>        sudo apt-get update && sudo apt-get install -y git
>     3. Create a folder "update_scripts" and cd to it
>     4. Clone the aws ami repository (containing the necessary scripts to update Ubuntu) from github
>        git clone --depth 1 https://github.com/UW-GAC/aws_ami
>     5. Update the server by executing the script:
>        ./upgrade_ubuntu_to_topmed.bash <R_version> <project ip> <home_ip> <admin_ip> [tomped rlib path
>  For example from the tm-workshop aws account,

>    `./upgrade_ubuntu_to_topmed.bash 3.3.2 172.255.39.161 172.255.40.179 172.255.41.187`

>  Or from the topmeddcc aws account:

>     `./upgrade_ubuntu_to_topmed.bash 3.3.2 172.255.44.97      172.255.36.89 172.255.40.251`

If the launched AMI has the desired functionality, a new AMI should be created from this launched image.
