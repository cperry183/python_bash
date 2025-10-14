#!/usr/bin/env bash 

who | cut -d ' ' -f 1 | sort -u 

#while read ID; do
#   squeue -u ${ID}; 
#done < user_list.txt

# for ID in $(user_list.txt); do squeue -u ${ID}; done 
# for ID in $(user_list.txt); do scontrol show job ${ID} | grep -i endtime;done 


