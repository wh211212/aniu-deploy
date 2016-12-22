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
#DATE=`date +Y-%m-%d`
Project=aniuapi
Project_dir=aniu-api
Remote_user=root
Remote_host=192.168.0.14
Remote_port=54077
#
Back_dir=/data/war_back/$Project
Wget_dir=/data/wget

Old_project=/data/svn
#New_project=/data/svn/aniu-project

deploy() {
# make sure define folder was created when you first execute this script, then you can annotation
[ -d $Back_dir ] || mkdir -p $Back_dir
[ -d $Wget_dir ] || mkdir -p $Wget_dir

# backup in use project war to back_dir
/bin/mv $Wget_dir/$Project.war $Back_dir/$Project_$Date.war

# upload project war from remote server 
/usr/bin/scp -P $Remote_port $Remote_user@$Remote_host:$Old_project/$Project_dir/target/$Project.war $Wget_dir/

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
  fi
#
  /bin/rm -rf $Project_dir/$Project*
  /bin/cp $Wget_dir/$Project.war $Project_dir/
  /bin/bash $Project_home/bin/startup.sh
#  echo "-----------------------------------------------------------------------------------"
  sleep 3
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
}

########################################################################
# checkrun: check service status
########################################################################
# 
checkrun() {
  # 
  ip=`ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
  for port in 8082 8083 8084
  do
  checkurl="http://$ip:$port/$Project/api/v2/video/commend?channelid=100211&clienttype=2&devid=800001&pno=1&productid=004&psize=3&time=20151110141945&type=2&sign=51c2e405b3e808256e209a9f44a35058"
  status_code=`curl -o /dev/null -m 10 --connect-timeout 10 -s -w %{http_code} $checkurl`
  if [ "$status_code" = "200" ]; then
       echo "*** deployment service $port start correctly. ***" 
       echo ""
       echo "*** $Date deployment $portservice correctly. ***" >> /data/script/deploy_correctly.log
    else
       echo "*** deployment service $port start incorrect. ***" 
       echo "*** $Date deployment $port service incorrect. ***" >> /data/script/deploy_incorrect.log
       exit 0
  fi
  sleep 1
done

}


# set main functions
main() {
  deploy
  echo "*** sleep 30 second waiting for service restart. ***"
  sleep 30
  echo "*** to determine whether the deployment service start correctly. *** "
  echo "---------------------------------------------------------------------"
  checkrun         
}

# call main function
main 
