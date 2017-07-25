#!/bin/bash
#往本机/etc/hosts添加hosts文件内容#############
#cat hosts  >> /etc/hosts;
echo "添加hosts到/etc/hosts文件完成";
host_ip=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
suffix_ip=${host_ip%.*}
suffix_ip=${suffix_ip%.*}
yum -y install mkisofs vim httpd python createrepo perl bind-utils openssh-clients ntp vim wget unzip bind
yum clean all
echo "开始配置ntp..."
chkconfig ntpd on 
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
#server	192.168.2.11	# local clock
fudge	127.127.1.0 stratum 10	

includefile /etc/ntp/crypto/pw

keys /etc/ntp/keys

" > /etc/ntp.conf
service ntpd restart && echo "ntp 配置完成!"
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc --localtime

# 配置selinux#############
echo "开始配置selinux..."
sed -i 's/enforcing/disabled/' /etc/selinux/config && echo "selinux 配置完成"

# 配置 iptalbes###########
echo "开始配置iptables..."
service iptables stop && chkconfig iptables off && service ip6tables stop && chkconfig ip6tables off && echo "iptables配置完成"

# 关闭 THP################
echo "关闭THP..."
echo "if test -f /sys/kernel/mm/redhat_transparent_hugepage/defrag;then echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag fi" >> /etc/rc.local && echo "闭THP完成"

echo "更新节点完成"
#安装jdk
echo " jdk 安装中"
rpm -e java-1.6.0-openjdk-1.6.0.38-1.13.10.4.el6.x86_64
rpm -e jdk-1.7.0_80-fcs.x86_64
rpm -e java-1.7.0-openjdk-1.7.0.99-2.6.5.1.el6.x86_64
cd /mnt/vrv/Packages/
rpm -ivh jdk-7u80-linux-x64.rpm
echo " jdk 安装完成"
read -p "install mysql，Please insert y or n ": name
if [ $name = "n" ]
then
  echo "不需要安装mysql"
elif [ $name = "y" ]
then
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
service mysql start
echo "安装mysql完成"
echo "初始化mysql"
mysqladmin -uroot password vrv123456.
echo "初始化mysql完成"
echo "增加客户端完成"
touch /etc/my.cnf
echo "
[client]
default-character-set=utf8
[mysqld]
character_set_server=utf8
lower_case_table_names=1
" >> /etc/my.cnf
service mysql restart
fi
