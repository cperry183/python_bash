#!/bin/bash

# ******************************************
#	   Program: Metal As a Service
#	   Script Name: MAAS-PXE.sh
# 	 Developer: Chad Perry
# 	 Date: 05-14-2016
#    Operating System: Ubuntu 16.04 LTS
# ******************************************
#
#Updating your Software
sudo apt-get update -y
#
#Installation of MAAS
sudo apt-get install maas -y
#
#Stay up-to-date with Release
#
sudo add-apt-repository ppa:maas/stable
#
#Create Mass Administrator
#
sudo maas-region-admin createadmin
#
#Going online to finish the Installation
echo "What is your IPv4 Address?"
/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'
echo "Please insert your IP here http://9.3.61.194:5240/MAAS/"
