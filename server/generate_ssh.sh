#!/bin/bash
if [ $# -lt 2 ]; then  
echo " HELP  
 generate_ssh.sh --generate ssh key for login without typing password;  
this script should run on the namenode machine and user should edit the ip-list file  
  
USAGE: ./generate_ssh.sh user pasaword  
  
EXAMPLE: ./generate_ssh root admin
HELP  
"
        exit 0  
fi 

yum -y install expect && echo "expect 安装完成"

user=$1
ip=$HOSTNAME
pass=$2
rm -rf /root/.ssh/*

echo "##################################"
echo " generate the rsa public key on $HOSTNAME ..."
echo "##################################"

expect -c "  
    set timeout -1  
    spawn ssh-keygen -t rsa
    expect \"*id_rsa*\" 
    send \"\r\"
    expect \"*passphrase*\" 
    send \"\r\"
    expect \"*again*\"
    send \"\r\"  
expect eof  
" 
cat /usr/bin/vasp/hosts | while read line
do
#提取ip
	ip_i=${line% *}
	full_hostname_i=${ip_i##* }
	ip_i=${ip_i% *}
	hostname_i=${line##* }
	expect -c "
	set timeout -1
	spawn ssh-copy-id -i /root/.ssh/id_rsa.pub $hostname_i
	expect \"yes/no\"
	send \"yes\r\"
	expect \"password:\"
	send \"$pass\r\"
	expect \"#\"
	
expect eof
"
done

echo "ssh配置完成"

#安装jdk
echo " jdk 安装中"
rpm -e java-1.6.0-openjdk-1.6.0.38-1.13.10.4.el6.x86_64
rpm -e jdk-1.7.0_80-fcs.x86_64
rpm -e java-1.7.0-openjdk-1.7.0.99-2.6.5.1.el6.x86_64
cd /mnt/vrv/Packages/
rpm -ivh jdk-7u80-linux-x64.rpm
echo " jdk 安装完成"

#安装mysql
echo "安装mysql中"
cd /mnt/vrv/Packages/
rpm -e mysql-5.1.73-7.el6.x86_64.rpm --nodeps
rpm -e --nodeps mysql-libs-5.1.73-7.el6.x86_64.rpm
yum remove -y mysql-libs
rm -fr /usr/lib/mysql
rm -fr /usr/include/mysql
rm -f /etc/my.cnf
rm -fr /var/lib/mysql
rpm -ivh MySQL-server-5.5.50-1.linux2.6.x86_64.rpm
rpm -ivh MySQL-client-5.5.50-1.linux2.6.x86_64.rpm

echo never > /sys/kernel/mm/redhat_transparent_hugepage/enabled
service mysql restart
service httpd restart
echo "安装mysql完成"
echo "初始化mysql"
mysqladmin -uroot password vrv123456.
echo "初始化mysql完成"
touch /etc/my.cnf
echo "
[client]
default-character-set=utf8
[mysqld]
character_set_server=utf8
lower_case_table_names=1
" >> /etc/my.cnf
service mysql restart
