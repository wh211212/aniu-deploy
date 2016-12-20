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
awk '{print $11}' $LOGFILE | sed -r 's@[^/]+[/]+([^/]+)/@\1@g' | sort | uniq -c | sort -rn | head -10
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
###########################################################################
#
echo "Most of the client type: "
echo "--------------------------------------------------------------------"
awk -F\" '{print $6}' $LOGFILE | sort | uniq -c | sort -rn | head -10
echo ""
###########################################################################
#
echo "Most of status code: "
echo "---------------------------------------------------------------------"
awk '{print $9}' $LOGFILE | sort | uniq -c | sort -rn | head -6
echo ""
##########################################################################
#200 - 请求已成功，请求所希望的响应头或数据体将随此响应返回。
#206 - 服务器已经成功处理了部分 GET 请求
#301 - 被请求的资源已永久移动到新位置
#302 - 请求的资源现在临时从不同的 URI 响应请求
#400 - 错误的请求。当前请求无法被服务器理解
#401 - 请求未授权，当前请求需要用户验证。
#403 - 禁止访问。服务器已经理解请求，但是拒绝执行它。
#404 - 文件不存在，资源在服务器上未被发现。
#500 - 服务器遇到了一个未曾预料的状况，导致了它无法完成对请求的处理。
#503 - 由于临时的服务器维护或者过载，服务器当前无法处理请求。
###########################################################################

