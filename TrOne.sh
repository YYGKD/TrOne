#!/bin/bash

install_start()
{
	read -p "请输入 transmission 账号 (默认账号:zhanghao): " UserName
	read -p "请输入 transmission 密码 (默认密码:mima): " PassWord
	read -p "请输入 transmission 端口 (默认端口:9091): " Port
	
	service transmissiond stop
	killall -9 transmission-da
	rm -rf /home/transmission
	rm -rf /usr/share/transmission
	rm -rf /etc/init.d/transmissiond
	yum install -y xz gcc gcc-c++ m4 make automake libtool gettext openssl-devel pkgconfig perl-libwww-perl perl-XML-Parser curl curl-devel libidn-devel zlib-devel which libevent

	cd /root
	wget https://github.com/Haknima/TrOne/raw/master/package/intltool-0.40.6.tar.gz
	tar -zxf intltool-0.40.6.tar.gz
	cd intltool-0.40.6
	./configure --prefix=/usr
	make && make install

	cd /root
	wget https://github.com/Haknima/TrOne/raw/master/package/libevent-2.0.21-stable.tar.gz
	tar -zxf libevent-2.0.21-stable.tar.gz
	cd libevent-2.0.21-stable
	./configure
	make && make install
	export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
	ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib/libevent-2.0.so.5
	ln -s /usr/local/lib/libevent-2.0.so.5.1.9 /usr/lib/libevent-2.0.so.5.1.9
	ln -s /usr/lib/libevent-2.0.so.5 /usr/local/lib/libevent-2.0.so.5
	ln -s /usr/lib/libevent-2.0.so.5.1.9 /usr/local/lib/libevent-2.0.so.5.1.9
	
	iptables -F
	iptables -X  
	iptables -I INPUT -p tcp -m tcp --dport 22:65535 -j ACCEPT
	iptables-save >/etc/sysconfig/iptables
	echo 'iptables-restore /etc/sysconfig/iptables' >> /etc/rc.local
}

install_transmission()
{
	cd /root
	wget https://github.com/Haknima/TrOne/raw/master/package/transmission-${version}.tar.xz
	tar -xf transmission*.tar.xz
	cd transmission*
	./configure --prefix=/usr
	make && make install

	cd /root
	useradd -m transmission
	passwd -d transmission
	wget https://github.com/Haknima/TrOne/raw/master/init.d/transmissiond
	mv transmissiond /etc/init.d
	chmod 755 /etc/init.d/transmissiond
	chkconfig --add transmissiond
	chkconfig --level 2345 transmissiond on
	mkdir -p /home/transmission/Downloads/
	chmod g+w /home/transmission/Downloads/
	mkdir /home/transmission/Torrents/
	chmod g+w /home/transmission/Torrents/
	mkdir /home/transmission/tmp/
	chmod g+w /home/transmission/tmp/
	mkdir -p /home/transmission/.config/transmission/
	wget https://github.com/Haknima/TrOne/raw/master/conf/settings.json
	mv -f settings.json /home/transmission/.config/transmission/settings.json
	chown -R transmission.transmission /home/transmission

	sed -i "s#zhanghao#${UserName}#" /home/transmission/.config/transmission/settings.json
	UserName=${UserName:-"zhanghao"}
	sed -i "s#mima#${PassWord}#" /home/transmission/.config/transmission/settings.json
	PassWord=${PassWord:-"mima"}
	sed -i "s#9091#${Port}#" /home/transmission/.config/transmission/settings.json
	Port=${Port:-"9091"}
}

install_web_control()
{
	wget https://github.com/ronggang/transmission-web-control/raw/master/release/install-tr-control-cn.sh
	bash install-tr-control-cn.sh auto
	service transmissiond start
}

install_flexget()
{
	read -p "请输入 rss 链接: " links

	cd /root
	yum install -y zlib zlib-devel readline-devel sqlite sqlite-devel openssl-devel mysql-devel gd-devel openjpeg-devel
	wget https://bootstrap.pypa.io/get-pip.py
	python get-pip.py
	pip install virtualenv
	virtualenv /root/flexget
	/root/flexget/bin/pip install flexget
	/root/flexget/bin/pip install transmissionrpc

	wget https://github.com/Haknima/TrOne/raw/master/conf/config.yml
	mv config.yml /root/flexget
	sed -i "s#links#${links}#" /root/flexget/config.yml
	/root/flexget/bin/flexget -c /root/flexget/config.yml execute

	yum -y install vixie-cron crontabs
	echo 'SHELL=/bin/bash' >> /var/spool/cron/root
	echo 'PATH=/sbin:/bin:/usr/sbin:/usr/bin' >> /var/spool/cron/root
	echo '*/5 * * * * /root/flexget/bin/flexget -c /root/flexget/config.yml execute' >> /var/spool/cron/root
	service crond restart
}

showMenu() 
{
	msg="
	欢迎使用 TrOne 安装脚本。
	GitHub 地址：https://github.com/Haknima/TrOne
	
	1. 安装 transmission2.93 + 美化；
	2. 安装 transmission2.92 + 美化；
	3. 安装 transmission2.84 + 美化；
	4. 安装或更新 transmission 美化；
	5. 安装 flexget rss插件(需python2.7及以上版本)；

	===================
	0. 退出安装；
	请输入对应的数字："
	echo -n "$msg"
	read flag
	echo ""
	case $flag in
		1)
			version=2.93
			install_start
			install_transmission
			install_web_control
			finishtr
			;;
		2)
			version=2.92
			install_start
			install_transmission
			install_web_control
			finishtr
			;;
		3)
			version=2.84
			install_start
			install_transmission
			install_web_control
			finishtr
			;;
		4)
			install_web_control
			;;
		5)
			install_flexget
			finishfl
			;;
		0)
			exit -1
			;;
	esac
}

finishtr()
{
	echo "#############################################################"
	echo "#Transmission 安装完成                                       "
	echo "#用户名: ${UserName} 密码: ${PassWord} 端口: ${Port}         "
	echo "#Web 地址为： http://ip:${Port}                              "
	echo "#Github 地址: https://github.com/Haknima/TrOne               "
	echo "#############################################################"
}

finishfl()
{
	echo "#############################################################"
	echo "#Flexget 安装完成                                           #"
	echo "#Github 地址: https://github.com/Haknima/TrOne              #"
	echo "#############################################################"
}

#Check Root
if [ $(id -u) != "0" ];then 
	echo "Error: You must be root to run this script"
	exit -1
else
	showMenu
fi
