#!/usr/bin/env bash 

set -x 
GROUP="$1"
CMD="$2"
LOG="$3"
timestamp=$(date +"%Y%m%d")

mkdir -p /home/chp6694/vuln_artifacts/vul_logs_${timestamp}
pdsh -g ${GROUP} '${CMD}' &> /tmp/${LOG}.log
mv /tmp/${LOG}.log /home/chp6694/vuln_artifacts/vul_logs_${timestamp}

