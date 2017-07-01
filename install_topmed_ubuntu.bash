#!/bin/sh
# install topmed packages and analysis pipeline
#    arg1: ip address of topmed_projects volume
#    optional arg2: R version
#    optional arg3: base path of the R library for topmed R packages
# 0. handle argument
PROJ_IP=$1
R_VERSION=${2:-3.3.2}
LIB_BASE_PATH=${3:-/projects/resources/gactools/R_packages}
# 1. mount the efs project folder
PFOLDER="/projects"
if [ ! -d "$PFOLDER" ]; then
  sudo mkdir $PFOLDER
  sudo chown ubuntu $PFOLDER
fi
# 2. mount the efs volume
if sudo mount | grep $PROJ_IP > /dev/null; then
    echo $PFOLDER already mounted
else
    sudo mount -t nfs4 -o vers=4.1 "$PROJ_IP":/ "$PFOLDER"
fi
# 3. create a path to R library
LIB_PATH=$LIB_BASE_PATH"/lib-R-"$R_VERSION
echo "Setting lib path for topmed R packages to $LIB_PATH"
if [ ! -d "$LIB_PATH" ]; then
    sudo mkdir "$LIB_PATH"
fi
# 4. call a python script to install topmed packages
RSCRIPT="installtopmed.R"
R_HOME="/usr/local/R-$R_VERSION/lib/R"
python ./install_topmed.py "$LIB_PATH" -s "$RSCRIPT"
if [ $? -eq 0 ]; then
    # we need set R_LIBS_SITE
    site_fn="$R_HOME/etc/Renviron.site"
    echo "R_LIBS_SITE=$LIB_PATH" > $site_fn
    # execute the script to install in site
    chmod +x "$RSCRIPT"
    ./"$RSCRIPT"
fi
# 5. install analysis_pipeliine
AP_PATH="/usr/local/src/topmed/analysis_pipeline"
if [ ! -d "$AP_PATH" ]; then
    mkdir /usr/local/src/topmed
    cd /usr/local/src/topmed
    git clone https://github.com/smgogarten/analysis_pipeline
    cd /usr/local/src/topmed/analysis_pipeline
    # we need set R_LIBS_SITE (just to make sure)
    site_fn="$R_HOME/etc/Renviron.site"
    echo "R_LIBS_SITE=$LIB_PATH" > $site_fn
    R CMD INSTALL TopmedPipeline
fi
