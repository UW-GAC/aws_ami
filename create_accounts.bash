#!/bin/bash
# install user accounts
#   arg1: base user name
#   optional arg2: number of accounts (def 5)
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

BASE_UNAME=${1:-topmed}
NO_USERS=${2:-5}

mgrp=topmed
if ! compgen -g | grep -x $mgrp > /dev/null; then
    sudo addgroup -gid 1002 $mgrp
fi
let CURRENT_USER=1
while [ $CURRENT_USER -le $NO_USERS ]; do
    USER=$BASE_UNAME"_"$CURRENT_USER
    echo "Checking user account $USER"
    if ! compgen -u | grep -x $USER > /dev/null; then
        sudo adduser --home /topmed_home/$USER --disabled-password --ingroup $mgrp  --gecos GECOS $USER
    fi
    rsgroup=rstudio-server
    if compgen -g | grep -x $rsgroup > /dev/null; then
        sudo usermod -a -G rstudio-server $USER
    fi
    sudo adduser $USER sudo
    PWD=$BASE_UNAME"server"$CURRENT_USER
    echo "$USER:$PWD" | sudo chpasswd
    let CURRENT_USER=CURRENT_USER-1
done
