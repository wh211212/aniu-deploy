#!/bin/bash
##########################################################################
# Script Name: batch_backup_repo.sh
# Author: shaon
# Email: shaonbean@qq.com
# Created Time: Wed 28 Dec 2016 12:03:59 PM CST
#########################################################################
# Blog address: http://blog.csdn.net/wh211212
#########################################################################
# Functions: batch backup current repo  #
# 
# Define some variables:  #
Repo_home=/etc/yum.repo.d
cd $Repo_home
for repo in $(ls *.repo)
do 
  mkdir -p ${Repo_home}/repo-backup
  /bin/mv ${repo} ${Repo_home}/repo-backup
done
# end
