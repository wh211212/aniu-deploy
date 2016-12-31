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
#########################################################################
# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root execute script!"
    exit 0
fi
# 
echo "+------------------------------------------------------------------------+"
echo "|       To initialization the system for security and performance        |"
echo "+------------------------------------------------------------------------+"

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
    # Make a user be only a user who can switch to root as an administration user
    #usermod -G wheel devops
    #echo "auth            required        pam_wheel.so use_uid" >> /etc/pam.d/su
  fi
}

############################################################################
disable-firewall() {
  #
  echo "*** disable firewall & selinux! ***"
  systemctl stop firewalld && systemctl disable firewalld 
  #
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  #
  setenforce 0
}

#
