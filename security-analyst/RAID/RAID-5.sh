#!/bin/bash

#########################################

# Program: RAID V Script
# Script Name: RAID-5.sh

# Developer: Chad B. Perry

# Date: 03-17-2016

#########################################

sudo apt-get -y update
sudo apt-get -y install hdparm lvm2 mdadm

#Add VM tuning stuff

vm.swappiness = 1

set low to limit swapping

vm.vfs_cache_pressure = 50

set lower to cache more inodes / dir entries

vm.dirty_background_ratio = 5

#set low on systems with lots of memory

#Too HIGH on systems with lots of memory

#means huge page flushes which will hurt IO performance

vm.dirty_ratio = 10

#set low on systems with lots of memory

DEFAULTS

BLOCKSIZE=4       				 # of filesystem in KB (should I determine?)
FORCECHUNKSIZE=true   			 # force max  sectors KB to chunk size > 512
TUNEFS=true       				 # run tune2fs on filesystem if ext[3|4]
SCHEDULER=deadline      	   	# cfq / noop / anticipatory / deadline
NR_REQUESTS=64       		    # NR REQUESTS
NCQDEPTH=31          		   # NCQ DEPTH
MDSPEEDLIMIT=200000     		# Array speed_limit_max in KB/s

#determine list of arrays

mdadm -Es | grep ARRAY | while read x1 x2 x3 x4 x5
do

INIT VARIABLES

RAIDLEVEL=0
NDEVICES=0
CHUNKSIZE=0
ARRAYSTATUS=0
DISKS=""
SPARES=""
NUMDISKS=0
NUMSPARES=0
NUMPARITY=0
NCQ=0
NUMNCQDISKS=0

RASIZE=0
MDRASIZE=0
STRIPECACHESIZE=0
MINMAXHWSECKB=999999999

STRIDE=0
STRIPEWIDTH=0

#GET DETAILS OF ARRAY

ARRAY=`basename $x2`
RAIDLEVEL=`echo $x3 | cut -d'=' -f2`

case $RAIDLEVEL in
"raid6") NUMPARITY=2 ;;
"raid5") NUMPARITY=1 ;;
"raid4") NUMPARITY=1 ;;
"raid3") NUMPARITY=1 ;;
"raid1") NUMPARITY=1 ;;
"raid0") NUMPARITY=0 ;;
*)
echo "Unknown RAID level"
esac

echo ""
echo 
