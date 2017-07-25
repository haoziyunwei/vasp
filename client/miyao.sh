#!/bin/bash
read -p "Please insert client ip": addr
ssh root@$addr
echo "已添加服务端公钥到客户端:$addr"
