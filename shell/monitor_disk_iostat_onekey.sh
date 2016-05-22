#!/bin/bash
############################################
#functions:monitor disk io status by one key
#auther:wh
##################################
#contact:
#    -- wh211212@qq.com
##################################
# changelog:
#  2016-05-22    vv    initial creation
##################################

#################################
#defined variable && parameter
#################################
zabbix_base=/opt/zabbix
scripts=$zabbix_base/scripts
cron=$zabbix_base/cron
data=$zabbix_base/data

################################
#save crontab jobs
crontab=/etc/cron.d

#to determime whether a folder
[ -f $scripts ] || mkdir -p $scripts
[ -f $cron ] || mkdir -p $cron
[ -f $data ] || mkdir -p $cron

#create discovery disk_name shell
cat > $scripts/diskname_discovery.sh << 'EOF'
#!/bin/bash
# function:monitor diskstatus from zabbix
# version:1.0 date:2016-04-01

  diskarray=($(grep '\b[a-z][a-z][a-z]\+\b'  /proc/diskstats|awk '{print $3}'))
  length=${#diskarray[@]}
  printf "{\n"
  printf  '\t'"\"data\":["
  for ((i=0;i<$length;i++))
  do
         printf '\n\t\t{'
         printf "\"{#DISK_NAME}\":\"${diskarray[$i]}\"}"
         if [ $i -lt $[$length-1] ];then
                 printf ','
         fi
  done
  printf  "\n\t]\n"
  printf "}\n"
EOF
chmod 755 $scripts/diskname_discovery.sh

#create iostat scripts gather data
cat > $cron/iostat_cron.sh << 'EOF'
#!/bin/bash
# info:
#  - cron job to gather iostat data
#  - can not do real time as iostat data gathering will exceed 
#    zabbix agent timeout
#  changelog:
#  20160519    vv    initial creation

iostat_bin="/usr/bin/iostat"
frequency="10 2"

# source data file
zabbix_base=/opt/zabbix
[ -d $zabbix_base/data ] || mkdir -p $zabbix_base/data

dest_data=$zabbix_base/data/iostat_data
tmp_data=$zabbix_base/data/iostat_data.tmp

#some configure,not nessesary
#script_conf=$zabbix_base/conf/iostat_check.conf
#[ -e "$script_conf" ] || touch $script_conf
#source $script_conf

# gather data in temp file first, then move to final location
# it avoids zabbix-agent to gather data from a half written source file
#
# iostat -dxm 10 2 - will display 2 lines : -m MB 
#  - 1st: statistics since boot -- useless
#  - 2nd: statistics over the last 10 sec
#
$iostat_bin -dxm $frequency > $tmp_data
mv $tmp_data $dest_data
EOF
chmod 755 $cron/iostat_cron.sh

#create crontab daemon
cat > $crontab/iostat << 'EOF'
# zabbix cronjob for application
*/2 * * * * /bin/bash /opt/zabbix/cron/iostat_cron.sh
EOF
chmod 755 $crontab/iostat

pid=`which crontab`
[ $pid -eq 0 ] || yum -y install cron*

#restart crontab daemon
/etc/init.d/cron restart

#modify zabbix_agentd.conf parameter
sed -i "s/#\ UnsafeUserParameters=0/UnsafeUserParameters=1/g" /opt/zabbix/etc/zabbix_agentd.conf
sed -i "s/# Include=\/usr\/local\/etc\/zabbix_agentd.conf.d/Include=\/opt\/zabbix\/etc\/zabbix_agentd.conf.d/" /opt/zabbix/etc/zabbix_agentd.conf
#

#create userparamter file,
cat > $zabbix_base/etc/zabbix_agentd.conf.d/userparameter_disk_iostat.conf << 'EOF'
#diskname discovery
UserParameter=disk.name.discovery[*],/opt/zabbix/scripts/diskname_discovery.sh $1
#gather iostat value
UserParameter=io.rrqmps[*],/usr/bin/tail /opt/zabbix/data/iostat_data |grep "\b$1\b"|tail -1|awk '{print $$3}'
UserParameter=io.wrqmps[*],/usr/bin/tail /opt/zabbix/data/iostat_data |grep "\b$1\b"|tail -1|awk '{print $$3}'
UserParameter=io.rps[*],/usr/bin/tail /opt/zabbix/data/iostat_data |grep "\b$1\b"|tail -1|awk '{print $$4}'
UserParameter=io.wps[*],/usr/bin/tail /opt/zabbix/data/iostat_data |grep "\b$1\b" |tail -1|awk '{print $$5}'
UserParameter=io.rMBps[*],/usr/bin/tail /opt/zabbix/data/iostat_data |grep "\b$1\b" |tail -1|awk '{print $$6}'
UserParameter=io.wMBps[*],/usr/bin/tail /opt/zabbix/data/iostat_data |grep "\b$1\b" |tail -1|awk '{print $$7}'
UserParameter=io.avgrq-sz[*],/usr/bin/tail /opt/zabbix/data/iostat_data |grep "\b$1\b" |tail -1|awk '{print $$8}'
UserParameter=io.avgqu-sz[*],/usr/bin/tail /opt/zabbix/data/iostat_data |grep "\b$1\b" |tail -1|awk '{print $$9}'
UserParameter=io.await[*],/usr/bin/tail /opt/zabbix/data/iostat_data |grep "\b$1\b" |tail -1|awk '{print $$10}'
UserParameter=io.svctm[*],/usr/bin/tail /opt/zabbix/data/iostat_data |grep "\b$1\b" |tail -1|awk '{print $$11}'
UserParameter=io.util[*],/usr/bin/tail /opt/zabbix/data/iostat_data |grep "\b$1\b" |tail -1|awk '{print $$12}'
EOF

#restart zabbix_agent daemon
/etc/init.d/zabbix_agent restart

#
retval=`netstat -nltp | grep zabbix | grep -v grep | wc -l`
[ $retval -gt 1 ] && echo "zabbix_agent restart succedd"

#local test defined key weather useful
$zabbix_base/bin/zabbix_get -s 127.0.0.1 -p 10050 -k disk.name.discovery >$data/disk_name.txt
if [ $? -eq 0 ];then
       echo disk.name.discovery is working.
   else
       echo diskname.discovery.sh has problem.
       exit 0
fi

#
grep DISK_NAME $data/diskname.txt | awk -F'["]' '{print $4}' >$data/disk_list.txt

for name in $data/disk_list.txt
         do 
         $zabbix_base/bin/zabbix_get -s 127.0.0.1 -p 10050 -k io.util[$name] > $data/util_data.txt
         done
util=`cat $data/util_data.txt | wc -l`
if [ $util -gt 1 ];then
       echo we defined userparameter is working.
   else
       echo dedfine key is not unsupported.
       exit 0
fi
    




