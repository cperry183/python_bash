#!/usr/bin/env bash 
set -x 

/opt/CrowdStrike//falconctl -d -f --cid
/opt/CrowdStrike//falconctl -s -f --cid=0F7C333B96DD4C7CB0286AFCFE0E3D30-15
for X in stop start status enable; do systemctl $X falcon-sensor.service; done
ps -e | grep falcon-sensor
