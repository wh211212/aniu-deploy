#/bin/bash
########################################################
# Functions: regular delete tomcat log 
# ChangeLog:
# 2016-11-17     shaonbean   initial 
########################################################
version=20161117
########################################################
# set variable 
# delete tomcat related log
for tomcat in tomcat_8082 tomcat_8083 tomcat_8083
  do
    find /data/$tomcat/logs -mtime +15 -type f | xargs rm -rf 
  done
sleep 2
# delete overdue backup war only save 7 day
back_dir=/data/war_back
find $back_dir -mtime +7 -name '*.war' | xargs rm -rf 
