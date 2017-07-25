#!/bin/sh
echo "VASP 1.1  install script"
echo "1.加固系统  2.安装vasp client 3.修改主机ip地址 4.修改主机名 5.修改网络 6.修改ambari主机地址 7.修改root密码 8.重启网络服务 9.退出"
echo "++++++++自动修改ip和主机名等相关信息+++++++++"
echo "ETHCONF=/etc/sysconfig/network-scripts/ifcfg-eth0"
echo "HOSTS=/etc/hosts"
echo "NETWORK=/etc/sysconfig/network"
echo "DIR=/data/backup/`date +%Y%m%d`" 
echo "NETMASK=255.255.255.0"
echo "安装好mysql默认密码为vrv123456."
echo "+++++++++-------------------------+++++++++++"
#Define Path 定义变量，可以根据实际情况修改 
 ETHCONF=/etc/sysconfig/network-scripts/ifcfg-eth0
 HOSTS=/etc/hosts
 NETWORK=/etc/sysconfig/network
 DIR=/data/backup/`date +%Y%m%d` 
 NETMASK=255.255.255.0 
  
echo "================================================"
echo
#定义change_ip函数 
function Change_ip () 
{ 
#判断备份目录是否存在，中括号前后都有空格，！叹号在shell表示相反的意思# 
if
 [ ! -d $DIR ];then
  
 mkdir -p $DIR 
  
fi
  
 echo "Now Change ip address ,Doing Backup Interface eth0"
 cp $ETHCONF $DIR 
  
 grep "dhcp" $ETHCONF 
#如下0用来判断上一次操作的状态，为0，表示上一次操作状态正确或者成功# 
if
  
 [ $? -eq 0 ];then
#read -p 交互输入变量IPADDR，注冒号后有空格，sed -i 修改配置文件# 
 read -p "Please insert ip Address:" IPADDR 
 read -p "Please insert gatway Address:" gateway
 sed -i 's/dhcp/static/g' $ETHCONF 
#awk -F. 意思是以.号为分隔域，打印前三列# 
 echo -e "IPADDR=$IPADDR\nNETMASK=$NETMASK\nGATEWAY=`echo $gateway|awk -F. '{print $1"."$2"."$3"."$4}'`" >>$ETHCONF 
 echo "This IP address Change success !"
  
else
  
 echo -n "This $ETHCONF is static exist ,please ensure Change Yes or NO": 
 read i 
  
fi
  
if
 [ "$i" == "y" -o "$i" == "yes" ];then
 read -p "Please insert ip Address:" IPADDR 
 read -p "Please insert gateway Address:" gateway
 count=(`echo |awk -F. '{print $1,$2,$3,$4}'`) 
 #定义数组， 0代表获取变量值总个数# 
 A=${#count[@]} 
 #while条件语句判断，个数是否正确，不正确循环提示输入，也可以用[0-9]来判断ip# 
while
  
 [ "$A" -ne "4" ] 
  
do
  
 read -p "Please re Inster ip Address,example 192.168.0.11 ip": IPADDR 
 count=(`echo $IPADDR|awk -F. '{print $1,$2,$3,$4}'`) 
 A=${#count[@]}
  
done
 #sed -e 可以连续修改多个参数# 
 sed -i -e 's/^IPADDR/#IPADDR/g' -e 's/^NETMASK/#NETMASK/g' -e 's/^GATEWAY/#GATEWAY/g' $ETHCONF 
 #echo -e \n为连续追加内容，并自动换行# 
 echo -e "IPADDR=$IPADDR\nNETMASK=$NETMASK\nGATEWAY=`echo $gateway|awk -F. '{print $1"."$2"."$3"."$4}'`" >>$ETHCONF 
 echo "This IP address Change success !"
else
 echo "This $ETHCONF static exist,please exit"
 exit $? 
  
fi
  
} 
  
#定义hosts函数 
############function hosts############## 
function Change_hosts () 
{ 
  
if
  
 [ ! -d $DIR ];then
 mkdir -p $DIR 
  
fi
  
 cp $HOSTS $DIR 
 read -p "Please insert ip address": IPADDR 
 read -p "Please insert ip hostname": hostname
 host=`echo $IPADDR|sed 's/\././g'` 
 cat $HOSTS |grep 127.0.0.1 |grep "$host"
   
if
 [ $? -ne 0 ];then
# sed -i "s/127.0.0.1/127.0.0.1 $host/g" $HOSTS
 echo "$host $hostname" >> /etc/hosts
 echo "This hosts change success "
  
else
 echo "This $host IS Exist .........."
  
fi
  
}
  
###########fuction network############### 
#定义network函数 
function Change_network () 
{ 
 if
  
 [ ! -d $DIR ];then
 mkdir -p $DIR 
  
 fi
 cp $NETWORK $DIR 
 read -p "Please insert host name": IPADDR 
  
 host=`echo $IPADDR|sed 's/\././g'` 
 grep "$host" $NETWORK 
  
 if
 [ $? -ne 0 ];then
 sed -i "s/^HOSTNAME/#HOSTNAME/g" $NETWORK 
 echo "HOSTNAME=$IPADDR" >>$NETWORK 
  
else
 echo "This $host IS Exist .........."
  
 fi
  
} 
function Change_rootpassword () 
{
read -p "Please insert you root password": password
echo $password | passwd --stdin root
}
function restart_server () 
{
echo "restart network server ...."
service network restart
ifup eth0
}
function exit_quit () 
{
echo "quit......"
break
}
function jiagu () 
{
cd /usr/bin/vasp/
sh jiagu.sh >>/usr/bin/vasp/jiagu.log
}

function install_vasp_client () 
{
cd /usr/bin/vasp/
sh create_local_yum.sh && sh update_master.sh >>/usr/bin/vasp/install.vasp_client.log
}

function add_key () 
{
cd /usr/bin/vasp/
sh miyao.sh
}

#PS3一般为菜单提示信息# 
 PS3="Please Select Menu": 
#select为菜单选择命令，格式为select $var in ..command.. do .... done 
 select i in "jiagu" "install_vasp_client" "Change_ip" "Change_hosts" "Change_network" "Change_rootpassword" "restart_server" "add_key" "exit_quit"
  
do
#case 方式，一般用于多种条件下的判断 
case $i in
  jiagu ) 
  jiagu 
;;
  install_vasp_client ) 
  install_vasp_client 
;;
  Change_ip ) 
  Change_ip 
;; 
  Change_hosts ) 
  Change_hosts 
;; 
  Change_network ) 
  Change_network 
;; 
  Change_rootpassword ) 
  Change_rootpassword
;; 
  restart_server ) 
  restart_server
;; 
  add_key ) 
  add_key
;; 
  exit_quit ) 
  exit_quit
;; 
  *) 
  echo
  echo "Please Insert $0: jiagu(1)|install_vasp_client(2)|Change_ip(3)|Change_hosts(4)|Change_network(5)|Change_rootpassword(6)|restart_network_server(7)|add_key(8)|quit(9)|"
  echo "温馨提示：请按8重启网络服务"
  break
;; 
esac 
done
