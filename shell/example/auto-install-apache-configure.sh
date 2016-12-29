#!/bin/bash
##########################################################################
# Script Name: auto-install-apache-configure.sh
# Author: shaon
# Email: shaonbean@qq.com
# Created Time: Wed 28 Dec 2016 06:14:18 PM CST
#########################################################################
# Blog address: http://blog.csdn.net/wh211212
#########################################################################
# Functions:  #
# 
# Define some variables:  #
#
yum -y install httpd

rm -f /etc/httpd/conf.d/welcome.conf
rm -f /etc/httpd/conf.d/welcome.conf

#
sed -i 's/ServerTokens OS/ServerTokens Prod/g' /etc/httpd/conf/httpd.conf
#
sed -i 's/KeepAlive Off/KeepAlive On/g' /etc/httpd/conf/httpd.conf
#
sed -i 's/ServerAdmin root@localhost/ServerAdmin root@mirrios.aniu.tv/g' /etc/httpd/conf/httpd.conf
#
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf

#
sed -i 's/ServerSignature On/ServerSignature Off/g' /etc/httpd/conf/httpd.conf






