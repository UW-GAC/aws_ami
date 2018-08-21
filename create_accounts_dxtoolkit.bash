#!/bin/bash
# install R
#   arg1: base user name
#   optional arg2: number of accounts (def 100)
BASE_UNAME=${1:-topmed}
NO_USERS=${2:-100}
SCRIPT=single_multichrom.sh
if [ "$#" -lt 1 ]; then
    echo "Error: No base user name passed"
    exit 1
fi
let CURRENT_USER=1
while [ $CURRENT_USER -le $NO_USERS ]; do
    USER=$BASE_UNAME"_"$CURRENT_USER
    echo "Checking user account $USER"
    if ! compgen -u | grep $USER > /dev/null; then
        sudo adduser --disabled-password --gecos GECOS $USER
    fi
    PWD="$(tr '[:lower:]' '[:upper:]' <<< ${BASE_UNAME:0:4})${BASE_UNAME:4}"_$NO_USERS
    echo "$USER:$PWD" | sudo chpasswd
    # copy over script
    sudo cp ./$SCRIPT /home/$USER
    sudo chown $USER /home/$USER/$SCRIPT
    let CURRENT_USER=CURRENT_USER+1
done
