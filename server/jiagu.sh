#!/bin/sh
# desc: setup linux system security
sed -i -e "s/PASS_MAX_DAYS.*$/PASS_MAX_DAYS  90/" -e "s/PASS_MIN_LEN.*$/PASS_MIN_LEN 8/"  /etc/login.defs  
echo "TMOUT=300" >>/etc/profile

# will system save history command list to 10
sed -i "s/HISTSIZE=1000/HISTSIZE=10/" /etc/profile

# enable /etc/profile go!
source /etc/profile

# add syncookie enable /etc/sysctl.conf
echo "net.ipv4.tcp_syncookies=1" >> /etc/sysctl.conf

sysctl -p # exec sysctl.conf enable
# optimizer sshd_config

sed -i "s/#MaxAuthTries 6/MaxAuthTries 6/" /etc/ssh/sshd_config
sed -i  "s/#UseDNS yes/UseDNS no/" /etc/ssh/sshd_config

echo "加固完成"
