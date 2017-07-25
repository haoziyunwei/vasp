#!/bin/sh
umount /dev/sr0
mkdir -p /var/www/html/HDP
mkdir -p /var/www/html/HDP-UTILS
read -p "Please insert source path": source
read -p "Please insert target path": target
echo "Iso file path is :" $source
echo 'Creating mount directory :' $target
mount $source $target
cp -rf $target/vrv/HDP/* /var/www/html/HDP/
echo "正在拷贝中"
cp -rf $target/vrv/HDP-UTILS-1.1.0.20/* /var/www/html/HDP-UTILS/
createrepo /var/www/html/HDP/
createrepo /var/www/html/HDP-UTILS/

rm -rf /etc/yum.repos.d/*
read -p "Please insert http addr": addr

echo "
[HDP]
name=HDP
baseurl=http://$addr/HDP
gpgcheck=0
enabled=1
priority=1
" >> /etc/yum.repos.d/hdp.repo

echo "
[HDP-UTILS]
name=HDP-UTILS
baseurl=http://$addr/HDP-UTILS
gpgcheck=0
enabled=1
priority=1
" >> /etc/yum.repos.d/hdp-utils.repo
echo "请访问 http://$addr/HDP"
echo "请访问 http://$addr/HDP-UTILS"

echo "
[vrv-http]
name=vrv-http
baseurl=http://$addr/centos/Packages/Packages
gpgcheck=0
enabled=1
" >> /etc/yum.repos.d/vrv-http.repo
echo "
[ambari-2.x]
name=Ambari 2.x
baseurl=http://$addr/ambari/
gpgcheck=0
enabled=1
priority=1
" >> /etc/yum.repos.d/ambari.repo
echo "
[vmp-extend-1.0]
name=vmp-extend-1.0
baseurl=http://$addr/vmp-extend/
gpgcheck=0
enabled=1
priority=1
" >> /etc/yum.repos.d/ambari.repo

yum clean all
