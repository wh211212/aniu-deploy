#!/bin/bash 
#################################################
#  --Info
#         Initialization CentOS 6.x script
#################################################
#  Changelog
#   20160601       wh           initial creation
#################################################
#   Auther: hwang@aniu.tv
################################################# 
# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to initialization OS"
    exit 1
fi

echo "+------------------------------------------------------------------------+"
echo "|       To initialization the system for security and performance        |"
echo "+------------------------------------------------------------------------+"

#check host && network
check_hosts()
{
    if grep -Eqi '^127.0.0.1[[:space:]]*localhost' /etc/hosts; then
        echo "Hosts: ok."
    else
        echo "127.0.0.1 localhost.localdomain localhost" >> /etc/hosts
    fi
    ping -c1 www.aniu.tv
    if [ $? -eq 0 ] ; then
        echo "DNS...ok"
    else
        echo "DNS...fail"
        echo -e "nameserver 202.96.209.133\nnameserver 202.96.209.6\nnameserver 114.114.114.114" > /etc/resolv.conf
    fi
}

#Set time zone synchronization

set_timezone()
{
    echo "Setting timezone..."
    rm -rf /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

    #install ntp
    echo "[+] Installing ntp..."
    /usr/sbin/ntpdate pool.ntp.org
    echo '*/5 * * * * /usr/sbin/ntpdate pool.ntp.org > /dev/null 2>&1' > /var/spool/cron/root;chmod 600 /var/spool/cron/root
    /sbin/service crond restart
}

#update os
update(){
    yum -y update $$ yum -y install wget
# change yum source   
#    cd /etc/yum.repos.d/
#    mkdir bak
#    mv ./*.repo bak
#    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
#    wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
#    yum clean all && yum makecache
    yum -y install vim unzip  openssl-client gcc gcc-c++ ntp sysstat iotop openssh-clients telnet lsof
    echo "yum update && yum install common command ......... succeed."
}

selinux()
{
       sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
       setenforce 0
       echo "disbale selinux ..................succeed."
}

#xen_hwcap_setting()
#{
#    if [ -s /etc/ld.so.conf.d/libc6-xen.conf ]; then
#        sed -i 's/hwcap 1 nosegneg/hwcap 0 nosegneg/g' /etc/ld.so.conf.d/libc6-xen.conf
#    fi
#}

#Modify file open number,define 1024
# /etc/security/limits.conf
limits_config()
{
cat >> /etc/security/limits.conf <<EOF
* soft nproc 65535
* hard nproc 65535
* soft nofile 8192
* hard nofile 8192
EOF
echo "ulimit -SHn 65535" >> /etc/rc.local
}

#Shut off system service

stop_server()
{ 
     echo "stop not nessccery services!"
     for server in `chkconfig --list |grep 3:on|awk '{ print $1}'`
         do
           chkconfig --level 3 $server off
         done
 
     for server in crond network rsyslog sshd lvm2-monitor sysstat netfs blk-availability udev-post
         do
           chkconfig --level 3 $server on
         done
}

#define sshd
sshd_config(){
    #sed -i '/^#Port/s/#Port 22/Port 54077/g' /etc/ssh/sshd_config
    sed -i '/^#UseDNS/s/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
    #sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
    sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
    /etc/init.d/sshd restart
    echo "set sshd && restat sshd succedd!"
}

# iptables
iptables(){
   #disable iptables
   /etc/init.d/iptables stop
   chkconfig --level 3 iptables off
   #disable ipv6
   echo "alias net-pf-10 off" >> /etc/modprobe.conf
   echo "alias ipv6 off" >> /etc/modprobe.conf
   echo "NETWORKING_IPV6=no" >> /etc/sysconfig/network
   chkconfig --level 3 ip6tables off
   /etc/init.d/ip6tables stop
   echo "iptables is stop && ipv6 is disabled!"
}

other(){
# initdefault
sed -i 's/^id:.*$/id:3:initdefault:/' /etc/inittab
/sbin/init q
# PS1
#echo 'PS1="\[\e[37;40m\][\[\e[32;40m\]\u\[\e[37;40m\]@\h \[\e[35;40m\]\W\[\e[0m\]]\\$ \[\e[33;40m\]"' >> /etc/profile
 
# Record command
sed -i 's/^HISTSIZE=.*$/HISTSIZE=500/' /etc/profile
#echo "export PROMPT_COMMAND='{ msg=\$(history 1 | { read x y; echo \$y; });user=\$(whoami); echo \$(date \"+%Y-%m-%d %H:%M:%S\"):\$user:\`pwd\`/:\$msg ---- \$(who am i); } >> /tmp/\`hostname\`.\`whoami\`.history-timestamp'" >> /root/.bash_profile
 
# wrong password five times locked 180s
sed -i '4a auth        required      pam_tally2.so deny=5 unlock_time=180' /etc/pam.d/system-auth
source /etc/profile
}

main(){
    check_hosts
    set_timezone
    selinux
    limits_config
    stop_server
    sshd_config
    iptables
    other
}
main
echo "+------------------------------------------------------------------------+"
echo "|            To initialization system all completed !!!                  |"
echo "+------------------------------------------------------------------------+"
