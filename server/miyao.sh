#!/bin/bash
cd /root/.ssh/
read -p "Please insert client ip": addr
cat id_rsa.pub >> authorized_keys 
scp id_rsa.pub authorized_keys root@$addr:/root/.ssh/
echo "已添加服务端公钥到客户端:$addr"
