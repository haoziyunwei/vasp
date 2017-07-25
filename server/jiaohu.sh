#!/bin/bash
#修改参数
echo never > /sys/kernel/mm/redhat_transparent_hugepage/enabled
sysctl vm.swappiness=10
#安装mysql驱动
echo "安装mysql驱动中"
#yum install mysql-connector-java -y
mkdir -p /usr/share/java/
cp -rf /mnt/vrv/vrv/vmp-extend-1.0/misc/mysql-connector-java-5.1.36.jar /usr/share/java/
mv /usr/share/java/mysql-connector-java-5.1.36.jar  /usr/share/java/mysql-connector-java.jar
#cp -rf /mnt/vrv/vmp-extend-1.0/misc/mysql-connector-java-5.1.36.jar /usr/share/java/
cp -rf /usr/share/java/mysql-connector-java.jar /usr/lib/ambari-server/
echo "安装mysql驱动完成"
ambari-server setup --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar
expect -c "  
spawn ambari-server setup
expect \"*continue*\" 
send \"y\r\"
expect \"*Customize*\" 
send \"y\r\"
expect \"*Enter*\"
send \"root\r\"  
expect \"*JDK*\"
send \"y\r\" 
expect \"*choice*\"
send \"3\r\" 
expect \"*JAVA*\"
send \"\/usr\/java\/default\r\" 
expect \"*configuration*\"
send \"y\r\" 
expect \"*choice*\"
send \"3\r\" 
expect \"*Hostname*\"
send \"vasp-manager\r\" 
expect \"*Port*\"
send \"3306\r\" 
expect \"*Database*\"
send \"ambari\r\" 
expect \"*Username*\"
send \"ambari\r\" 
expect \"*Database*\"
send \"ambari\r\" 
expect \"*Re-enter*\"
send \"ambari\r\" 
expect \"*properties*\"
send \"y\r\" 	
expect eof  
" 
cd /mnt/vrv/vrv/vmp-extend-1.0/
sh vmp-extend-1.0.sh
echo "api.csrfPrevention.enabled=false" >>/etc/ambari-server/conf/ambari.properties
ambari-server start
yum install dos2* -y
dos2unix /usr/bin/vasp/*.sh
echo "安装server端完成"
