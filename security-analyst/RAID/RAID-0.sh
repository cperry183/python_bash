#!/bin/bash

# ******************************************
#	 Program: RAID V Script
#	 Script Name: RAID-5.sh
# 	 Developer: Chad B. Perry
# 	 Date: 03-17-2016
# ******************************************


# NEED FOLLOWING UTILS
# -- hdparm
# -- lvm

# Added VM tuning stuff
# vm.swappiness = 1               
# set low to limit swapping
# vm.vfs_cache_pressure = 50      
# set lower to cache more inodes / dir entries
#vm.dirty_background_ratio = 5  
# set low on systems with lots of memory
# Too HIGH on systems with lots of memory 
# means huge page flushes which will hurt IO performance                                                           
# vm.dirty_ratio = 10            
# set low on systems with lots of memory


# DEFAULTS
BLOCKSIZE=4		# of filesystem in KB (should I determine?)
FORCECHUNKSIZE=true	# force max  sectors KB to chunk size > 512
TUNEFS=true		# run tune2fs on filesystem if ext[3|4]
SCHEDULER=deadline      # cfq / noop / anticipatory / deadline
NR_REQUESTS=64          # NR REQUESTS
NCQDEPTH=31             # NCQ DEPTH
MDSPEEDLIMIT=200000     # Array speed_limit_max in KB/s


# determine list of arrays
mdadm -Es | grep ARRAY | while read x1 x2 x3 x4 x5
do
    # INIT VARIABLES
    RAIDLEVEL=5
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


    # GET DETAILS OF ARRAY
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
    echo "======================================================================"
    echo "FOUND ARRAY - $ARRAY / $RAIDLEVEL"
    CHUNKSIZE=`mdadm --detail /dev/$ARRAY | grep 'Chunk Size' | tr -d A-Za-z':'[:blank:]`

    echo "-- Chunk Size = $CHUNKSIZE KB"

    FOO1=`grep "$ARRAY : " /proc/mdstat`
    ARRAYSTATUS=`echo $FOO1 | cut -f 3`


    # GET LIST OF DISKS IN ARRAY
    echo ""
    echo "Getting active devices and spares list"
    for DISK in `echo $FOO1 | cut -f 5- -d \ `
    do
	LETTER=`echo $DISK | cut -c 1-3`
	echo $DISK | grep '(S)'
        RC=$?
	if [ $RC -gt 0 ]
	then
	    echo "-- $DISK - Active"
	    DISKS="$DISKS $LETTER"
	    NUMDISKS=$((NUMDISKS+1))
	else
	    echo "-- $DISK - Spare"
	    SPARES="$SPARES $LETTER"
	    NUMSPARES=$((NUMDISKS+1))
	fi
    done
    echo ""
    echo "Active Disks ($NUMDISKS) - $DISKS"
    echo "Spares Disks ($NUMSPARES) - $SPARES"

        
    # DETERMINE SETTINGS
    RASIZE=$(($NUMDISKS*($NUMDISKS-$NUMPARITY)*2*$CHUNKSIZE))  # Disk read ahead in 512byte blocks
    MDRASIZE=$(($RASIZE*$NUMDISKS))                            # Array read ahead in 512byte blocks
    STRIPECACHESIZE=$(($RASIZE*2/8))                           # in pages per device


    for DISK in $DISKS $SPARES
    do
	# check max_hw_sectors_kb
	FOO1=`cat /sys/block/$DISK/queue/max_hw_sectors_kb | awk '{print $1}'`
	if [ $FOO1 -lt $MINMAXHWSECKB ]
	then
	    MINMAXHWSECKB=$FOO1
	fi

	# check NCQ
	hdparm -I /dev/$DISK | grep NCQ >> /dev/null
	if [ $? -eq 0 ]
	then
	    NUMNCQDISKS=$((NUMNCQDISKS+1))
	fi
    done

    if [ $CHUNKSIZE -le $MINMAXHWSECKB ]
    then
	MINMAXHWSECKB=$CHUNKSIZE
    fi

    if [ $NUMNCQDISKS -lt $NUMDISKS ]
    then
	NCQDEPTH=1
	echo "WARNING! ONLY $NUMNCQDISKS DISKS ARE NCQ CAPABLE!"
    fi

    echo ""
    echo "TUNED SETTINGS"
    echo "-- DISK READ AHEAD  = $RASIZE blocks"
    echo "-- ARRAY READ AHEAD = $MDRASIZE blocks"
    echo "-- STRIPE CACHE     = $STRIPECACHESIZE pages"
    echo "-- MAX SECTORS KB   = $MINMAXHWSECKB KB"
    echo "-- NCQ DEPTH        = $NCQDEPTH"

    # TUNE ARRAY
    echo ""
    echo "TUNING ARRAY"
    blockdev --setra $MDRASIZE /dev/$ARRAY
    echo "-- $ARRAY read ahead set to $MDRASIZE blocks"

    echo "$STRIPECACHESIZE" > /sys/block/$ARRAY/md/stripe_cache_size
    echo "-- $ARRAY stripe_cache_size set to $STRIPECACHESIZE pages"

    echo $MDSPEEDLIMIT > /proc/sys/dev/raid/speed_limit_max
    echo "-- $ARRAY speed_limit_max set to $MDSPEEDLIMIT"

    # TUNE DISKS
    echo ""
    echo "TUNING DISKS"
    echo "Settings : "
    echo "        read ahead = $RASIZE blocks"
    echo "    max_sectors_kb = $MINMAXHWSECKB KB"
    echo "         scheduler = $SCHEDULER"
    echo "       nr_requests = $NR_REQUESTS"
    echo "       queue_depth = $NCQDEPTH"

    
    for DISK in $DISKS $SPARES
    do
	echo "-- Tuning $DISK"
	blockdev --setra $RASIZE /dev/$DISK
	echo $MINMAXHWSECKB > /sys/block/$DISK/queue/max_sectors_kb
	echo $SCHEDULER > /sys/block/$DISK/queue/scheduler
	echo $NR_REQUESTS > /sys/block/$DISK/queue/nr_requests
	echo $NCQDEPTH > /sys/block/$DISK/device/queue_depth
    done

    # TUNE ext3/exti4 FILESYSTEMS
    STRIDE=$(($CHUNKSIZE/$BLOCKSIZE))
    STRIPEWIDTH=$(($CHUNKSIZE/$BLOCKSIZE*($NUMDISKS-$NUMPARITY)))
    echo ""
    echo "TUNING FILESYSTEMS"
    echo "For each filesystem on this array, run the following command:"
    echo "  tune2fs -E stride=$STRIDE,stripe-width=$STRIPEWIDTH <filesystem>"
    echo ""

done