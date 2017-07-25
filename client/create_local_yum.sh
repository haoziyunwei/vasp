#!/bin/bash
iso_path=/dev/sr0
echo "Iso file path is :" /dev/sr0
yum_path=/mnt/vrv/
echo 'Creating mount directory :' /mnt/vrv
mkdir -p /mnt/vrv/
mount /dev/sr0 /mnt/vrv
echo 'Updating /etc/yum.repos.d/ files...'
rm -rf /etc/yum.repos.d/*
touch /etc/yum.repos.d/vrv.repo
echo "
[vrv-local]
name=vrv-local
baseurl=file:///mnt/vrv
gpgcheck=0
enabled=1
" >> /etc/yum.repos.d/vrv.repo
yum clean all && echo 'yum repository has been updated! '
host_ip=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
echo "$host_ip vasp-manager" >>/usr/bin/vasp/hosts
#echo "$host_ip vasp-manager" >>/etc/hosts
