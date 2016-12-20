#!/bin/bash
##########################################################################
# Script Name: backup_svn_code.sh
# Author: shaon
# Email: shaonbean@qq.com
# Created Time: Tue 20 Dec 2016 09:05:12 AM CST
#########################################################################
# Blog address: http://blog.csdn.net/wh211212
#########################################################################
# Define some variables #
SVNDIR=/data/svnroot
SVNADMIN=/usr/bin/svnadmin
DATE=`date +%Y-%m-%d`
OLDDATE=`date +%Y-%m-%d -d '30 days'`
BACKDIR=/data/backup/svn-backup

# create backup dir if not exist
[ -d ${BACKDIR} ] || mkdir -p ${BACKDIR}

# define svn backup log & backup dir
LogFile=${BACKDIR}/svnbak.log
mkdir ${BACKDIR}/${DATE}

# use svnadmin backup svn code & compress
for project in njdx wx aniu
   do
   cd ${SVNDIR}
   ${SVNADMIN} hotcopy $project ${BACKDIR}/${DATE}/$project --clean-logs
   cd ${BACKDIR}/${DATE}
   tar zcvf $project_svn_${DATE}.tar.gz $project
   rm -rf $project
sleep 2
done

# sync backup svn code to ftp_server
