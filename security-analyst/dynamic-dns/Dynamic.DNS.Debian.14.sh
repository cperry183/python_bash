#!/bin/bash

# **************************************************
#	   Program: Setting Up Dynamic DNS
#	   Script Name: DDNS.sh
# 	 Developer: Chad Perry and Frank Frank Liu
# 	 Date: 05-17-2016
#    Operating System: Ubuntu 14.04 LTS
# **************************************************

#Installation of ddclient
sudo apt-get update -y; apt-get upgrade -y;
sudo apt-get install ddclient -y;

Edit the ddclient.conf
cat << EOM >> /etc/ddclient.conf
daemon=3600
ssl=yes
use=web, web=checkip.dyndns.com/, web-skip='IP Address'
EOM
#
#Ensure the Configuration file is working
sudo ddclient -daemon=0 -debug -verbose -noquiet;
#
#Restart ddclient
service ddclient restart
#
#Setting up a Cron Tab
crontab -e
* */1 * * * python /home/chadp/update_dns
