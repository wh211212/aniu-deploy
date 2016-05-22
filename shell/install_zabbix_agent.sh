#!/bin/bash
#########################################
# Author:  wh
# function: install zabbix server one key
# set -xv
# conntact
#    -- wh211212@qq.com
#########################################
# changelog:
#  2016-05-01    vv    initial creation
#########################################
server="192.168.5.5"       #
version="zabbix-3.0.1"
package=/usr/local/src
zblog=/var/log/zabbix
zbpid=/opt/zabbix/pid

#install gcc
yum -y install gcc gcc-c++ openssh-clients net-snmp*  
 if [ $? -eq 0 ];then
    echo "yum install successed"
  else
    echo "yum install failed"
    exit 2
 fi
#create zabbix group if not exists  
egrep "^zabbix" /etc/group >& /dev/null  
 if [ $? -ne 0 ]  
 then  
    groupadd zabbix  
 fi
#create user if not exists  
egrep "^zabbix" /etc/passwd >& /dev/null  
 if [ $? -ne 0 ]  
 then  
    useradd -g zabbix zabbix -s /bin/nologin  
 fi 
#wget zabbix.tar.gz
#scp -P 22 root@192.168.1.154:$package/$version.tar.gz $package
wget -P ${package} -c http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/3.0.1/zabbix-3.0.1.tar.gz
 if [ -e "$package/$version.tar.gz" ]; then
   echo "wget is successed"
 else
   echo "wget is failed"
   exit 2
 fi
#compile zabbix
cd $package
tar -zxvf $version.tar.gz
cd $package/$version
./configure --prefix=/opt/zabbix --enable-agent 
#find / -name mysql_config
make && make install
if [ $? -eq 0 ];
  then
  echo "Installation completed !"
  else
  echo "Installation failed"
  exit 2
fi
#define log path
mkdir -p $zblog
mkdir -p $zbpid
chown zabbix:zabbix $zblog
chown zabbix:zabbix $zbpid
#
cp -r $package/$version/misc/init.d/fedora/core/zabbix_agentd /etc/rc.d/init.d/
chmod 744 /etc/init.d/zabbix_agentd
sed -i "s#BASEDIR=/usr/local#BASEDIR=/opt/zabbix#g" /etc/init.d/zabbix_agentd
#softlink
ln -s /opt/zabbix/bin/zabbix_get /usr/bin/
ln -s /opt/zabbix/bin/zabbix_sender /usr/bin/
ln -s /opt/zabbix/sbin/zabbix_agentd /usr/sbin/
#service port add
cat >>/etc/services <<EOF
zabbix-agent 10050/tcp         #Zabbix Agent
zabbix-agent 10050/udp         #Zabbix Agent
zabbix-trapper 10051/tcp       #Zabbix Trapper
zabbix-trapper 10051/udp       #Zabbix Trapper
EOF
#edit zabbix_agentd.conf file
sed -i "s/Server\=127.0.0.1/Server=127.0.0.1,$server/g" /opt/zabbix/etc/zabbix_agentd.conf
sed -i "s#tmp/zabbix_agentd.log#var/log/zabbix/zabbix_agentd.log#g" /opt/zabbix/etc/zabbix_agentd.conf
sed -i "s#tmp/zabbix_agentd.pid#opt/zabbix/pid/zabbix_agentd.pid#g" /opt/zabbix/etc/zabbix_agentd.conf
sed -i "s/#\ Timeout=3/Timeout=5/g" /opt/zabbix/etc/zabbix_agentd.conf
#sed -i "s/#\ Include=\/usr\/local\/etc\/zabbix_agentd.conf.d/Include=\/opt\/zabbix\/etc\/zabbix_agentd.conf.d/g" /opt/zabbix/etc/zabbix_agentd.conf
sed -i "s/#\ UnsafeUserParameters=0/UnsafeUserParameters=1/g" /opt/zabbix/etc/zabbix_agentd.conf
#start zabbix_agentd
#chkconfig add zabbix_agentd
chkconfig zabbix_agentd on
chkconfig zabbix_server on
/etc/init.d/zabbix_agentd restart
/etc/init.d/zabbix_server restart
#netstat -nltp | grep --color zabbix
revtel=`netstat -nltp | grep zabbix | grep -v grep | wc -l` 
if [ $revtel -eq 0 ];then
    echo "zabbix_server install successed"
 else
    echo "zabbix_server install failed"
fi
