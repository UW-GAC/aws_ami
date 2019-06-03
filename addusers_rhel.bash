#!/bin/bash
# create the topmed group
mgroup=topmed
if ! compgen -g | grep $mgroup > /dev/null; then
    sudo groupadd --gid 1002 $mgroup
    # update ec2-user account (current login)
    sudo usermod -a -G $mgroup ec2-user
    sudo usermod -g $mgroup ec2-user
fi
# create user account
echo ">>> Creating UW user accounts  ..."

uaccnt=levined
if ! compgen -u | grep $uaccnt > /dev/null; then
    sudo useradd -d /topmed_home/$uaccnt -u 1002 -g $mgroup -G docker -m  $uaccnt
fi

uaccnt=kuraisa
if ! compgen -u | grep $uaccnt > /dev/null; then
    sudo useradd -d /topmed_home/$uaccnt -u 1001 -g $mgroup -G docker -m  $uaccnt
fi

uaccnt=sdmorris
if ! compgen -u | grep $uaccnt > /dev/null; then
    sudo useradd -d /topmed_home/$uaccnt -u 1003 -g $mgroup -G docker -m  $uaccnt
fi

uaccnt=mchughc
if ! compgen -u | grep $uaccnt > /dev/null; then
    sudo useradd -d /topmed_home/$uaccnt -u 1010 -g $mgroup -G docker -m  $uaccnt
fi

uaccnt=mconomos
if ! compgen -u | grep $uaccnt > /dev/null; then
    sudo useradd -d /topmed_home/$uaccnt -u 1011 -g $mgroup -G docker -m  $uaccnt
fi

uaccnt=amarise
if ! compgen -u | grep $uaccnt > /dev/null; then
    sudo useradd -d /topmed_home/$uaccnt -u 1012 -g $mgroup -G docker -m  $uaccnt
fi

uaccnt=avmikh
if ! compgen -u | grep $uaccnt > /dev/null; then
    sudo useradd -d /topmed_home/$uaccnt -u 1013 -g $mgroup -G docker -m  $uaccnt
fi

uaccnt=calaurie
if ! compgen -u | grep $uaccnt > /dev/null; then
    sudo useradd -d /topmed_home/$uaccnt -u 1014 -g $mgroup -G docker -m  $uaccnt
fi

uaccnt=analyst
if ! compgen -u | grep $uaccnt > /dev/null; then
    sudo useradd -d /topmed_home/$uaccnt -u 1099 -g $mgroup -G docker -m  $uaccnt
fi
