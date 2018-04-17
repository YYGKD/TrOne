#!/bin/bash

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

clear
echo
echo "###########################################################"
echo "# One click Install transmission script for Centos 7      #"
echo "# Github: https://github.com/Haknima/Transmission         #"
echo "# Author: Haknima                                         #"
echo "###########################################################"
echo

#清空删除transmission
service transmissiond stop
killall -9 transmission-da
rm -rf /home/transmission
rm -rf /usr/share/transmission
rm -rf /etc/init.d/transmissiond

#依赖
yum install -y wget xz gcc gcc-c++ m4 make automake libtool gettext openssl-devel pkgconfig perl-libwww-perl perl-XML-Parser curl curl-devel libidn-devel zlib-devel which libevent
yum install -y zlib zlib-devel readline-devel sqlite sqlite-devel openssl-devel mysql-devel gd-devel openjpeg-devel

#依赖包
cd /root
wget https://github.com/Haknima/Transmission/raw/master/intltool-0.40.6.tar.gz
tar -zxf intltool-0.40.6.tar.gz
cd intltool-0.40.6
./configure --prefix=/usr
make -s
make -s install

cd /root
wget https://github.com/Haknima/Transmission/raw/master/libevent-2.0.21-stable.tar.gz
tar -zxf libevent-2.0.21-stable.tar.gz
cd libevent-2.0.21-stable
./configure
make -s
make -s install
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib/libevent-2.0.so.5
ln -s /usr/local/lib/libevent-2.0.so.5.1.9 /usr/lib/libevent-2.0.so.5.1.9
ln -s /usr/lib/libevent-2.0.so.5 /usr/local/lib/libevent-2.0.so.5
ln -s /usr/lib/libevent-2.0.so.5.1.9 /usr/local/lib/libevent-2.0.so.5.1.9

#主程序
cd /root
wget https://github.com/Haknima/Transmission/raw/master/transmission-2.84.tar.gz
tar -zxf transmission-2.84.tar.gz
cd transmission-2.84
./configure --prefix=/usr
make -s
make -s install

#配置文件
useradd -m transmission
passwd -d transmission
mv transmission.sh /etc/init.d/transmissiond
chmod 755 /etc/init.d/transmissiond
chkconfig --add transmissiond
chkconfig --level 2345 transmissiond on
mkdir -p /home/transmission/Downloads/
chmod g+w /home/transmission/Downloads/
mkdir -p /home/transmission/.config/transmission/
cd /root
wget https://github.com/Haknima/Transmission/raw/master/settings.json
mv -f settings.json /home/transmission/.config/transmission/settings.json
chown -R transmission.transmission /home/transmission

#修改配置信息
read -p "请输入 transmission 账号 (默认账号:zhangha): " UserName
read -p "请输入 transmission 密码 (默认密码:mima): " PassWord
read -p "请输入 transmission 端口 (默认端口:9091): " Port
sed -i "s#zhangha#${UserName}#" /home/transmission/.config/transmission/settings.json
sed -i "s#mima#${PassWord}#" /home/transmission/.config/transmission/settings.json
sed -i "s#9091#${Port}#" /home/transmission/.config/transmission/settings.json

#防火墙规则
iptables -t nat -F
iptables -t nat -X
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT
iptables -t nat -P OUTPUT ACCEPT
iptables -t mangle -F
iptables -t mangle -X
iptables -t mangle -P PREROUTING ACCEPT
iptables -t mangle -P INPUT ACCEPT
iptables -t mangle -P FORWARD ACCEPT
iptables -t mangle -P OUTPUT ACCEPT
iptables -t mangle -P POSTROUTING ACCEPT
iptables -F
iptables -X
iptables -P FORWARD ACCEPT
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t raw -F
iptables -t raw -X
iptables -t raw -P PREROUTING ACCEPT
iptables -t raw -P OUTPUT ACCEPT
service iptables save

#安装美化
cd /root
wget https://github.com/ronggang/transmission-web-control/raw/master/release/install-tr-control-cn.sh
bash install-tr-control-cn.sh
service transmissiond start

#flexget
cd /root
wget https://bootstrap.pypa.io/get-pip.py --no-check-certificate
python get-pip.py
pip install virtualenv
virtualenv /root/flexget
/root/flexget/bin/pip install flexget
/root/flexget/bin/pip install transmissionrpc

#flexget 配置
mkdir /home/transmission/Torrents
wget https://github.com/Haknima/Transmission/raw/master/config.yml
mv config.yml /root/flexget
read -p "请输入 rss 链接: " links
sed -i "s#links#${links}#" /root/flexget/config.yml
sed -i "s#zhangha#${UserName}#" /root/flexget/config.yml
sed -i "s#mima#${PassWord}#" /root/flexget/config.yml
sed -i "s#9091#${Port}#" /root/flexget/config.yml
/root/flexget/bin/flexget -c /root/flexget/config.yml execute

#定时任务
yum -y install vixie-cron crontabs
echo 'SHELL=/bin/bash' >> /var/spool/cron/root
echo 'PATH=/sbin:/bin:/usr/sbin:/usr/bin' >> /var/spool/cron/root
echo '*/5 * * * * /root/flexget/bin/flexget -c /root/flexget/config.yml execute' >> /var/spool/cron/root
/sbin/service crond restart

#完成
echo "#############################################################"
echo "# 安装完成                                                   #"
echo "# 用户名: ${UserName} 密码: ${PassWord} 端口: ${Port}         #"
echo "# Web 地址为： http://ip:${Port}                              #"
echo "# Github: https://github.com/Haknima/Transmission            #"
echo "#############################################################"
