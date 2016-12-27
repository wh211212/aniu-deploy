#!/bin/bash
##########################################################################
# Script Name: auto-install-rabbitmq-server.sh
# Author: shaon
# Email: shaonbean@qq.com
# Created Time: Mon 26 Dec 2016 01:52:32 PM CST
#########################################################################
# Blog address: http://blog.csdn.net/wh211212
#########################################################################
# Functions: The script be used for auto install RabbitMQ  #
# ENV: CentOS release 6.8 (Final) 

################################################
#               configure repo                 #
################################################
epel-repo() {
#rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
# rpm -ivh http://mirrors.aliyun.com/epel/epel-release-latest-6.noarch.rpm
# cd /usr/local/src
# wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
# unstall aliyun epel
rpm -qa | grep epel
rpm -e epel-release-6-8.noarch 
find / -type d -name epel -exec rm -rf {} \;
# install fedoraproject epel
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
if [ $? -eq 0 ];then
  echo " intsall epel repo succeed!"
  else
  echo " install epel repo failed!" 
}

##################################################################
#    Configure system hosts, scripts use rabbitmq-1,2 example    #
##################################################################
#
config-host() {
ip=`ifconfig | grep -v '127.0.0.1' | awk '/inet addr/{print substr($2,6)}'`
host=`hostname`
egrep "${ip} ${host}" /etc/hosts >/dev/null 2>&1
if [ $? -eq 0 ];then
  echo " ******　Host has been configured! ******"
  else
  echo "${ip} ${host}" >> /etc/hosts
fi
}

#######################################################################
#    Remove Erlang & RabbitMQ if exists                               #
#######################################################################
#
remove-rpm() {
# remove erlang
rpm -qa | grep erlang 
if [ $? -eq 0 ];then
  echo "*** Erlang has been installed. Need to uninstall first! ***"
  yum remove erlang* -y
# remove associate dir  
#  for package in erlang rabbitmq-server
#  do
  find / -type d -name erlang -exec rm -rf {} \;
#  done
  else
  echo "*** Erlang has not been installed. Don't need to uninstall! ***"
fi

# uninstall rabbitmq
 rpm -qa | grep rabbitmq-server
 if [ $? -eq 0 ];then
   echo "*** RabbbitMQ has been installed. Need to uninstall first! ***"
   yum remove rabbitmq-server -y
   find / -type d -name erlang -exec rm -rf {} \;
   else              
   echo "*** RabbitMQ has not been installed. Don't need to uninstall! ***"
   echo ""
 fi
}

########################################################################
#       create erlang solutions repo & rabbitmq repo                   #
########################################################################
create-repo(){
# create erlang solutions repo
cat > /etc/yum.repos.d/erlang-solutions.repo << 'EOF'
[erlang-solutions]
name=Centos $releasever - $basearch - Erlang Solutions
baseurl=https://packages.erlang-solutions.com/rpm/centos/$releasever/$basearch
gpgcheck=1
gpgkey=https://packages.erlang-solutions.com/rpm/erlang_solutions.asc
enabled=1
EOF
# to determine whether a source to create succeed
if [ $? -eq 0 ];then
    echo "*** create erlang solutions repo succeed! ***"
    echo ""
  else
    echo "*** create erlang solutions repo failed! ***" 
    exit 0
fi

# create rabbitmq-server.repo 
cat > /etc/yum.repos.d/rabbitmq-server.repo << 'EOF'
[rabbitmq-server]
name=rabbitmq-server
baseurl=https://packagecloud.io/rabbitmq/rabbitmq-server/el/6/$basearch
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
#
[rabbitmq_rabbitmq-server-source]
name=rabbitmq_rabbitmq-server-source
baseurl=https://packagecloud.io/rabbitmq/rabbitmq-server/el/6/SRPMS
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
EOF
#
if [ $? -eq 0 ];then
    echo "*** create rabbitmq repo succeed! ***"
    echo ""
  else
    echo "*** create rabbitmq repo failed! ***" 
    exit 0
fi
}

#########################################################
#        reset yum makecache                            #
#########################################################
yum-install() {
yum clean all && yum makecache

# yum install erlang & rabbitmq-server
if [ $? -eq 0 ];then
  echo " Erlang repo & rabbitmq-server repo have been created succeed! "
  yum install erlang -y && yum install rabbitmq-server -y
  else
  echo " Erlang repo & rabbitmq-server repo have been created failed! "
  exit 0
fi
}

######################################################
#     use rabbitmq-server configure some things      #
######################################################
use-rabbitmq() {
  # use_rabbitmq-server atfer then install succeed
  yum-install
  # start rabbitmq-server & chkconfig 
  /etc/init.d/rabbitmq-server start && chkconfig rabbitmq-server on
  # use rabbitmqctl configure, add user, list users, change users password, granting admin role to users, delete user
  # user=devops
  # passwd=password
  rabbitmqctl add_user devops password
  # rabbitmqctl list_users
  rabbitmqctl list_users
  # change user password
  rabbitmqctl change_password devops anwg123.
  # granting users
  rabbitmqctl set_user_tags devops administrator
  # delete users
  # rabbitmqctl delete_user devops

  # use rabbitmqctl configure virtulhost
  # rabbitmqctl add_vhost [vhost]
  rabbitmqctl add_vhost /aniu_vhost 
  # show vhost list
  # rabbitmqctl list_vhosts 
  # deleting vhost is like follows
  # rabbitmqctl delete_vhost /aniu_vhost

  ## To grant permissions to a user for virtualhosts, configure like follows
  # rabbitmqctl set_permissions [-p vhost] [user] [permission ⇒ (modify) (write) (read)]
  rabbitmqctl set_permissions -p /aniu_vhost devops ".*" ".*" ".*" 
  # show permission for a vhost
  # rabbitmqctl list_permissions -p /aniu_vhost
  # show permission of a specific user
  # rabbitmqctl list_user_permissions devops
  # deleting permission of a specific user is like follows
  # rabbitmqctl clear_permissions -p /aniu_vhost devops

}

#############################################################
#              RabbitMQ : Use Web UI                        #
#############################################################
# Enable Management Plugin to use Web based administration tool
rabbitmq-manage() {
rabbitmq-plugins enable rabbitmq_management

# restart RabbitMQ for changes to take effect
/etc/init.d/rabbitmq-server restart
}
# Access to the "http://(RabbitMQ server's hostname or IP address):15672/" from a client, then, RabbitMQ login form is displayed, login with an admin user you added. Before should be disable ipatbles & selinux.

########################################################
#   Define main function call child functions          #
########################################################
main() {
epel-repo
config-host
remove-rpm
create-repo
yum-install
#use-rabbitmq
#rabbitmq-manage
}

# Suggestion:
# If you know erlang & rabbitmq don't installed, you can nonuse remove-rpm functions, if you use remove-rpm,after execute scripts succeed remove remove-rpm from the main functions.

main

###############################################################
if [ $? -eq 0 ];then
    echo "****************************************************"
    echo "***    Congratulation install RabbitMQ Succeed!  ***"
    echo "****************************************************"
  else
    echo "****************************************************"
    echo "***    Congratulation install RabbitMQ Succeed!  ***" 
    echo "****************************************************"
    exit 0
fi
###############################################################
