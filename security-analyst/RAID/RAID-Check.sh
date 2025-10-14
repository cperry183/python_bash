#!/bin/bash

# ******************************************
#	 Program: RAID V Script
#	 Script Name: RAID-Check.sh
# 	 Developer: Chad B. Perry
# 	 Date: 03-17-2016
# ******************************************


#Get controller number
controller=`tw_cli show | tail -2 | head -1  | awk '{print $1}'`

#Set Email
email='chadp@us.ibm.com'

#Get Hostname
hostname=`/bin/hostname`

#Build Reports
/sbin/tw_cli info $controller > /tmp/raidreport
/sbin/tw_cli alarms >> /tmp/raidreport

#Check Raid Status
raidstatus=`/usr/bin/head -n4 /tmp/raidreport | /usr/bin/tail -n 1 | /usr/bin/awk '{print $3}'`

#Send email if needed
if [ $raidstatus != "OK" ] && [ $raidstatus != "VERIFYING" ]
then
        /usr/bin/mail $email -s"3Ware RAID health report for $hostname: Raid Degraded" < /tmp/raidreport
fi

#Clean Up
/bin/rm -rf /tmp/raidreport
