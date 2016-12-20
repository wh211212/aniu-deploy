#!/bin/bash
#############################################################################
# Functions: auto deploy api project, base on tomcat
#############################################################################
# ChangeLog:
# 2016-12-19    wanghui    initial create
#
#############################################################################
# set some variables
Date=`date +%F_%T`
DATE=`date +Y-%m-%d`
Project=aniuapi
Back_dir=/data/war_back/$Project
Wget_dir=/data/wget

Old_project=/data/svn
#New_project=/data/svn/aniu-project

# make sure define folder was created
[ -d $Back_dir ] || mkdir -p $Back_dir
[ -d $Wget_dir ] || mkdir -p $Wget_dir

# backup in use project war to back_dir
/bin/mv $Wget_dir/$Project.war $Back_dir/$Project_$Date.war

# upload project war from remote server 
/usr/bin/scp -P54077 root@192.168.0.14:$Old_project/aniu-api/target/$Project.war $Wget_dir/

for port in 8082 8083 8084
  do
  Tomcat_port=tomcat_$port
  Project_home=/data/$Tomcat_port
  Project_dir=$Project_home/webapps
#  echo "*** First step shutdown $Tomcat_port ***"
  /bin/bash $Project_home/bin/shutdown.sh
  tomcat_status=`ps -ef | grep $Tomcat_port | grep -v grep | awk '{print $2}' | wc -l`
  if [ $tomcat_status -eq 0 ];then
       echo "*** $Tomcat_port auto shutdown succeed!  ***"
    else
#       echo "*******************************************************************************"
#       echo "*** $Tomcat_port auto shutdown failed,then should force shutdown $Tomcat_port! " 
       ps -ef | grep $Tomcat_port | grep -v grep | awk '{print $2}' | xargs kill -9
       tomcat_pid=`ps -ef | grep $Tomcat_port | grep -v grep | awk '{print $2}'`
       /bin/kill -9 tomcat_pid
  fi
  /bin/rm -rf $Project_dir/$Project*
  /bin/cp $Wget_dir/$Project.war $Project_dir/
  /bin/bash $Project_home/bin/startup.sh
#  echo "-----------------------------------------------------------------------------------"
  tomcat_pid=`ps -ef | grep $Tomcat_port | grep -v grep | awk '{print $2}'`
  if [ $tomcat_pid -ne 0 ];then
     echo "*************************************************"
     echo "***      $Tomcat_port auto start succeed !    ***"
     echo "*************************************************"
  else
     echo "### $Tomcat_port auto start failed! #####"
     echo "#########################################"
  fi
done
