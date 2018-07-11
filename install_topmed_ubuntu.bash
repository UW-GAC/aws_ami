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

R_VERSION=${1:-3.5.1}
AP_BRANCH=${2:-master}

ANALYSIS_PIPELINE_BRANCH=$AP_BRANCH
echo "Building version of  $ANALYSIS_PIPELINE_BRANCH ..."

# install topmed pipeline
cd /usr/local/src
if [ ! -d /usr/local/src/analysis_pipeline ]; then
    git clone -b $ANALYSIS_PIPELINE_BRANCH https://github.com/UW-GAC/analysis_pipeline.git
    # execute R script to install topmed packages
    cd /usr/local/src/analysis_pipeline
    Rscript --vanilla --no-save --slave install_packages.R

    # create a link analysis_pipeline
    if [ -d /usr/local/analysis_pipeline ]; then
        unlink /usr/local/analysis_pipeline
    fi

    ln -s /usr/local/src/analysis_pipeline /usr/local/analysis_pipeline
else
    echo "analysis_pipeline and topmed packages already installed"
fi
