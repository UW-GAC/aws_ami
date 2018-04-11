#!/bin/bash
# install topmed packages and analysis pipeline
#    optional arg1: R version
#    optional arg2: branch of analysis pipeline
# 0. handle argument
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

R_VERSION=${1:-3.3.4}
AP_BRANCH=${2:-devel}
# call a python script to install topmed packages
RSCRIPT="installtopmed.R"
R_HOME="/usr/local/R-$R_VERSION/lib/R"
if [ -f $RSCRIPT ]; then
    rm $RSCRIPT
fi
python ./install_topmed_ubuntu.py  -s "$RSCRIPT"
if [ $? -eq 0 ]; then
    if [ -f $RSCRIPT ]; then
        echo "Installing TOPMed packages ..."
        chmod +x "$RSCRIPT"
        ./"$RSCRIPT"
    fi
fi
# install analysis_pipeliine
AP_PATH="/usr/local/analysis_pipeline"
if [ ! -d "$AP_PATH" ]; then
    echo "Installing analysis_pipeline ..."
    cd /usr/local
    git clone -b $AP_BRANCH https://github.com/UW-GAC/analysis_pipeline.git
    cd $AP_PATH
    R CMD INSTALL TopmedPipeline
else
    echo "Analysis_pipeline already installed"
fi
