#!/bin/bash
##########################################################################
# Script Name: install-jdk-tomcat-env.sh
# Author: shaon
# Email: shaonbean@qq.com
# Created Time: Thu 09 Feb 2017 03:52:33 PM CST
#########################################################################
# Blog address: http://blog.csdn.net/wh211212
#########################################################################
# Functions:  #
# 
# Define some variables:  #

#
date=`date +%F_%T`
apps=/opt/tomcats

# download tomcat
version=7.0.75
wget_url=http://mirrors.hust.edu.cn/apache/tomcat/tomcat-7/v$version/bin/apache-tomcat-$version.tar.gz
