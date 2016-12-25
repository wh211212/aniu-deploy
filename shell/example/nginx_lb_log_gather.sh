#!/bin/bash
##########################################################################
# Script Name: nginx_lb_log_gather.sh
# Author: shaon
# Email: shaonbean@qq.com
# Created Time: Tue 20 Dec 2016 09:56:01 AM CST
#########################################################################
# Blog address: http://blog.csdn.net/wh211212
#########################################################################
# use example
# bash nginx_lb_log_gather.sh nginx.log.file
# Define some variables #################################################
#
if [ $# -eq 0 ];then
  echo "Error: please specify logfile."
  exit 0
  else
    LOGFILE=$1
fi

#
if [ ! -f $1 ];then
  echo "Sorry,I can't find this nginx logfile,please make sure your logfile name is right and try again!"
  exit 0
fi
##########################################################################
# 
echo "Most of the ip: "
echo "-------------------------------------------------------------------"
awk '{print $1}' $LOGFILE | sort | uniq -c | sort -nr | head -10
echo "###################################################################"
#
echo "Most of the time: "
echo "-------------------------------------------------------------------"
awk '{print $4}' $LOGFILE | cut -c 14-18 | sort | uniq -c | sort -nr | head -10
echo ""
##########################################################################
echo "Most of the page: "
echo "-------------------------------------------------------------------"
wk '{print $11}' $LOGFILE | sed -r 's@[^/]+[/]+([^/]+)/@\1@g' | sort | uniq -c | sort -rn | head -10
echo ""
##########################################################################
#
echo "Most of the time/Most of the ip: "
echo "-------------------------------------------------------------------"
awk '{print $4}' $LOGFILE | cut -c 14-18 | sort | uniq -c | sort -nr | head -10 > timelog
for i in `awk '{print $2}' timelog`
  do 
    num=`grep $i timelog | awk '{ print $1 }'` 
    echo " $i $num "
    ip=`grep $i $LOGFILE | awk '{print $1}' | sort -n | uniq -c | sort -nr | head -10`
    echo "$ip"
    echo ""
  done
rm -f timelog

