#!/bin/bash

read -p "请输入 rss 链接: " links

yum install -y zlib zlib-devel readline-devel sqlite sqlite-devel openssl-devel mysql-devel gd-devel openjpeg-devel
yum -y install vixie-cron crontabs

cd /root
wget https://bootstrap.pypa.io/get-pip.py --no-check-certificate
python get-pip.py
pip install virtualenv
virtualenv /root/flexget
/root/flexget/bin/pip install flexget
/root/flexget/bin/pip install transmissionrpc

#flexget 配置
mkdir /home/transmission/Torrents
wget https://github.com/Haknima/Transmission/raw/master/conf/config.yml
mv config.yml /root/flexget
sed -i "s#links#${links}#" /root/flexget/config.yml
sed -i "s#zhanghao#${UserName}#" /root/flexget/config.yml
sed -i "s#mima#${PassWord}#" /root/flexget/config.yml
sed -i "s#9091#${Port}#" /root/flexget/config.yml
/root/flexget/bin/flexget -c /root/flexget/config.yml execute

#定时任务
echo 'SHELL=/bin/bash' >> /var/spool/cron/root
echo 'PATH=/sbin:/bin:/usr/sbin:/usr/bin' >> /var/spool/cron/root
echo '*/5 * * * * /root/flexget/bin/flexget -c /root/flexget/config.yml execute' >> /var/spool/cron/root
/sbin/service crond restart
