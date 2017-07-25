#!/bin/bash
#安装ambari
echo "安装ambari中"
rpm -e vmp-i18n-2.1.1.0
yum -y install ambari-server
echo "安装ambari完成"
mysql -uroot -pvrv123456. -e "
grant all on *.* to root@'%' identified by 'vrv123456.';
flush privileges; 
CREATE USER 'ambari'@'%' IDENTIFIED BY 'ambari';
grant all privileges on *.* to 'ambari'@'%' identified by 'ambari' with grant option; 
CREATE USER 'ambari'@'localhost' IDENTIFIED BY 'ambari';
grant all privileges on *.* to 'ambari'@'localhost' identified by 'ambari' with grant option;
CREATE USER 'ambari'@'vasp-manager' IDENTIFIED BY 'ambari'; 
grant all privileges on *.* to 'ambari'@'vasp-manager' identified by 'ambari' with grant option; 
flush privileges; 
CREATE USER 'hive'@'%' IDENTIFIED BY 'hive';
grant all privileges on *.* to 'hive'@'%' identified by 'hive' with grant option; 
CREATE USER 'hive'@'localhost' IDENTIFIED BY 'hive';
grant all privileges on *.* to 'hive'@'localhost' identified by 'hive' with grant option;
CREATE USER 'hive'@'vasp-manager' IDENTIFIED BY 'hive';
grant all privileges on *.* to 'hive'@'vasp-manager' identified by 'hive' with grant option; 
flush privileges;
CREATE USER 'oozie'@'%' IDENTIFIED BY 'oozie';
GRANT ALL PRIVILEGES ON *.* TO 'oozie'@'%';
FLUSH PRIVILEGES;
create database ambari default charset='UTF8';
create database hive default charset='UTF8';
create database oozie default charset='UTF8';
quit" 
mysql -uroot -pvrv123456. -e "
use ambari;
SOURCE /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql;
quit"
