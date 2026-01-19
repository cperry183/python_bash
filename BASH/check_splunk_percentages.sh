#!/usr/bin/env bash 

today=$(date +%d/%m/%Y) 
month_dir=/tmp/$today
mkdir -p $month_dir

pdsh -w gitlab01,devop01 'if [ ! -f /etc/systemd/system/SplunkForwarder.service ]; then echo "Not found on $(hostname)"; else ls /etc/systemd/system/SplunkForwarder.service'; fi > $month_dir
