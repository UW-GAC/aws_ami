#!/bin/bash
# install emacs
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

EMACS_VERSION=26.1
EMACS_RDIR=/usr/local/src/emacs
EMACS_TAR=emacs-$EMACS_VERSION.tar.gz
if [ ! -d $EMACS_RDIR ]; then
    sudo mkdir $EMACS_RDIR
fi

cd $EMACS_RDIR
if [ ! -f $EMACS_TAR ]; then
    echo "Downloading $EMACS_TAR ..."
    sudo wget https://ftp.gnu.org/gnu/emacs/$EMACS_TAR
    sudo tar -xzvf $EMACS_TAR
    cd emacs-$EMACS_VERSION
    echo "Buildig emacs without X ..."
    sudo ./configure --without-x --with-gnutls=no
    sudo make
    sudo make install
else
    echo "emacs-$EMACS_VERSION is already installed. "
fi
