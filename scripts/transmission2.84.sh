#!/bin/bash

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

clear

read -p "请输入 transmission 账号 (默认账号:zhanghao): " UserName
read -p "请输入 transmission 密码 (默认密码:mima): " PassWord
read -p "请输入 transmission 端口 (默认端口:9091): " Port

#清空删除残留
service transmissiond stop
killall -9 transmission-da
rm -rf /home/transmission
rm -rf /usr/share/transmission
rm -rf /etc/init.d/transmissiond

#依赖
yum install -y gcc gcc-c++ m4 make automake libtool gettext openssl-devel pkgconfig perl-libwww-perl perl-XML-Parser curl curl-devel libidn-devel zlib-devel which libevent

#依赖包
cd /root
wget https://github.com/Haknima/Transmission/raw/master/package/intltool-0.40.6.tar.gz
tar -zxf intltool-0.40.6.tar.gz
cd intltool-0.40.6
./configure --prefix=/usr
make && make install

cd /root
wget https://github.com/Haknima/Transmission/raw/master/package/libevent-2.0.21-stable.tar.gz
tar -zxf libevent-2.0.21-stable.tar.gz
cd libevent-2.0.21-stable
./configure
make && make install
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib/libevent-2.0.so.5
ln -s /usr/local/lib/libevent-2.0.so.5.1.9 /usr/lib/libevent-2.0.so.5.1.9
ln -s /usr/lib/libevent-2.0.so.5 /usr/local/lib/libevent-2.0.so.5
ln -s /usr/lib/libevent-2.0.so.5.1.9 /usr/local/lib/libevent-2.0.so.5.1.9

#主程序
cd /root
wget https://github.com/Haknima/Transmission/raw/master/package/transmission-2.84.tar.gz
tar -zxf transmission-2.84.tar.gz
cd transmission-2.84
./configure --prefix=/usr
make && make install

#配置文件
cd /root
useradd -m transmission
passwd -d transmission
wget https://github.com/Haknima/Transmission/raw/master/init.d/transmissiond
mv transmissiond /etc/init.d
chmod 755 /etc/init.d/transmissiond
chkconfig --add transmissiond
chkconfig --level 2345 transmissiond on
mkdir -p /home/transmission/Downloads/
chmod g+w /home/transmission/Downloads/
mkdir -p /home/transmission/.config/transmission/
wget https://github.com/Haknima/Transmission/raw/master/conf/settings.json
mv -f settings.json /home/transmission/.config/transmission/settings.json
chown -R transmission.transmission /home/transmission

#修改配置信息
sed -i "s#zhanghao#${UserName}#" /home/transmission/.config/transmission/settings.json
sed -i "s#mima#${PassWord}#" /home/transmission/.config/transmission/settings.json
sed -i "s#9091#${Port}#" /home/transmission/.config/transmission/settings.json

#安装美化
cd /root
wget https://github.com/ronggang/transmission-web-control/raw/master/release/install-tr-control-cn.sh
bash install-tr-control-cn.sh auto
service transmissiond restart
