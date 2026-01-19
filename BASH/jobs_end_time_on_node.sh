#!/usr/bin/env bash 

if [ -z "$1" ]
  then
    HOST="localhost"
else
    HOST=$1
fi
echo HOST: $HOST;


squeue -w $HOST --noheader |awk '{print $1}'|xargs -I % scontrol show job %|grep  EndTime|awk '{print $2}'|sort -u 
