#!/bin/bash
#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

echo
echo "####################################################################"
echo "# One click Install transmission script                            #"
echo "# Github: https://github.com/Haknima/One-click-transmisson-script  #"
echo "# Author: Haknima                                                  #"
echo "####################################################################"
