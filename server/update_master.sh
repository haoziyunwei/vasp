#!/bin/bash
#往本机/etc/hosts添加hosts文件内容#############
#cat hosts  >> /etc/hosts;
#echo "添加hosts到/etc/hosts文件完成";
host_ip=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
suffix_ip=${host_ip%.*}
suffix_ip=${suffix_ip%.*}
cd /mnt/vrv/Packages/
#rpm -ivh python-deltarpm-3.5-0.5.20090913git.el6.x86_64.rpm
yum -y install mkisofs vim httpd createrepo perl python bind-utils openssh-clients ntp vim wget unzip bind && chkconfig httpd on && mkdir -p /var/www/html/centos && mkdir -p /var/www/html/centos/Packages/Packages && mkdir -p  /var/www/html/ambari/ && mkdir -p /var/www/html/vmp-extend/ && echo "拷贝文件中..." && cp -rf /mnt/vrv/Packages/* /var/www/html/centos/Packages/Packages/ && echo "拷贝文件完成，生成源中..." && createrepo /var/www/html/centos/Packages/Packages/ && rm -rf /etc/yum.repos.d/* && echo "http源拷贝完成，更新yum..."
cp -rf /mnt/vrv/system/* /var/www/html/
touch /etc/yum.repos.d/vrv-http.repo
echo "
[vrv-http]
name=vrv-http
baseurl=http://$host_ip/centos/Packages/Packages
gpgcheck=0
enabled=1
" >> /etc/yum.repos.d/vrv-http.repo
service httpd restart && chkconfig httpd on && yum clean all
echo "http 源已经配置完成"
echo "开始配置dns..."
echo "开始配置ntp..."
chkconfig ntpd on 
#cp ntp.conf /etc/ntp.conf 
# 写入ntp.conf文件
echo "
driftfile /var/lib/ntp/drift
restrict default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery

restrict 127.0.0.1 
restrict -6 ::1
restrict $suffix_ip.0.0 mask 255.255.0.0 nomodify notrap

restrict 0.vrv.pool.ntp.org mask 255.255.255.255 nomodify notrap noquery
restrict 1.vrv.pool.ntp.org mask 255.255.255.255 nomodify notrap noquery
restrict 2.vrv.pool.ntp.org mask 255.255.255.255 nomodify notrap noquery
#server 210.72.145.44
server	127.127.1.0	# local clock
fudge	127.127.1.0 stratum 10	

includefile /etc/ntp/crypto/pw

keys /etc/ntp/keys

" > /etc/ntp.conf
service ntpd restart && echo "ntp 配置完成!"
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc --localtime


## 配置 hdp yum####################
echo "开始配置ambari..."
mkdir -p /var/www/html/ambari/
mkdir -p /var/www/html/vmp-extend/
cp -rf /mnt/vrv/vrv/AMBARI-2.2.1.0/centos6/2.2.1.0-161/*   /var/www/html/ambari/
cp -rf /mnt/vrv/vrv/vmp-extend-1.0/*    /var/www/html/vmp-extend/
createrepo  /var/www/html/vmp-extend/
createrepo /var/www/html/ambari/
# 写入文件
touch /etc/yum.repos.d/ambari.repo
touch /etc/yum.repos.d/vmp-extend.repo

echo "
[ambari-2.x]
name=Ambari 2.x
baseurl=http://$host_ip/ambari/
gpgcheck=0
enabled=1
priority=1
" >> /etc/yum.repos.d/ambari.repo

echo "
#cd /mnt/vrv/vrv/vmp-extend-1.0
#chmod 777 vmp-extend-1.0.sh
#sh vmp-extend-1.0.sh
[vmp-extend-1.0]
name=vmp-extend-1.0
baseurl=http://$host_ip/vmp-extend/
gpgcheck=0
enabled=1
priority=1
" >> /etc/yum.repos.d/vmp-extend.repo

yum clean all && echo "ambari 配置完成"

# 配置selinux#############
echo "开始配置selinux..."
sed -i 's/enforcing/disabled/' /etc/selinux/config && echo "selinux 配置完成"

# 配置 iptalbes###########
echo "开始配置iptables..."
service iptables stop && chkconfig iptables off && service ip6tables stop && chkconfig ip6tables off && echo "iptables配置完成"

# 关闭 THP################
echo "关闭THP..."
echo "if test -f /sys/kernel/mm/redhat_transparent_hugepage/defrag;then echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag fi" >> /etc/rc.local && echo "闭THP完成"

echo "更新主节点完成"
