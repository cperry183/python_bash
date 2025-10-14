#!/usr/bin/env bash

HUID=$1
echo "user => $HUID" 
squeue -u ${HUID} | awk '
BEGIN {
    abbrev["R"]="(Running)"
    abbrev["PD"]="(Pending)"
    abbrev["CG"]="(Completing)"
    abbrev["F"]="(Failed)"
}
NR>1 {a[$5]++}
END {
    for (i in a) {
        printf "%-2s %-12s %d\n", i, abbrev[i], a[i]
    }
}'

echo 
echo  
echo "checking user jobs"
ps -aux | grep $HUID


