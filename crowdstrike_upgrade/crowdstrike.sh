#!/usr/bin/env bash 

yum remove falcon-sensor -y  
yum install -y /home/chp6694/bash_scripts/crowdstrike_upgrade/falcon-sensor-6.57.0-15402.el7.x86_64.rpm
/opt/CrowdStrike/falconctl -s --cid=0F7C333B96DD4C7CB0286AFCFE0E3D30-15
systemctl start falcon-sensor
ps -e | grep falcon-sensor
