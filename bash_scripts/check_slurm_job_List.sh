#!/usr/bin/env bash

# Check if the input file is provided as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file="$1"
# Loop through each HUID in the input file
while IFS= read -r HUID; do
    echo "user => $HUID" 
    squeue -u "${HUID}" | awk '
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
    ps -aux | grep "$HUID"
    echo "" 
done < "$input_file"


