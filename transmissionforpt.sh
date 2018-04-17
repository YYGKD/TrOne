#!/bin/bash

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

clear
echo
echo "###########################################################"
echo "# One click Install transmission script for Centos 7      #"
echo "# Github: https://github.com/Haknima/One-click-pt         #"
echo "# Author: Haknima                                         #"
echo "###########################################################"
echo

#依赖
yum install -y wget xz gcc gcc-c++ m4 make automake libtool gettext openssl-devel pkgconfig perl-libwww-perl perl-XML-Parser curl curl-devel libidn-devel zlib-devel which libevent
yum install -y zlib zlib-devel readline-devel sqlite sqlite-devel openssl-devel mysql-devel gd-devel openjpeg-devel

