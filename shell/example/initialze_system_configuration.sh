#!/bin/bash
##########################################################################
# Script Name: initialze_system_configuration.sh
# Author: shaon
# Email: shaonbean@qq.com
# Created Time: Fri 30 Dec 2016 10:30:28 AM CST
#########################################################################
# Blog address: http://blog.csdn.net/wh211212
#########################################################################
# Functions: initialze system configuration #
# ENV: CentOS 7
# Define some variables:  #
# add user
#########################################################################
add-user() {
  #
  user=devops
  egrep ${user} /etc/passwd >/devnull 2>&1
  if [ $? -eq 0 ];then
    echo "*** ${user} already exists! ***"
    else
    useradd ${user}
    echo anwg123. | passwd --stdin ${user}
    mkdir -p /home/${user}/{backup,scripts}
    echo "*** user add succeed!  ***"
    # grant user
    echo "${user}  ALL=(ALL)       NOPASSWD:ALL" >> /etc/sudoers
  fi
}

#

