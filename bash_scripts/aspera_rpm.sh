#!/usr/bin/env bash 
set -x 

# Variables
TIMESTAMP=$(date +"%Y_%m_%d_%I_%M_%p")

# Create two files
TRANSFER=`rpm -qa PACKAGE_NAME >> $(hostname -s)_aspera_${TIMESTAMP}.log - on transfer host`
YUM=`rpm -qa PACKAGE_NAME >>  $(hostname -s)_aspera_${TIMESTAMP}.log - on $REPO`

if cmp --silent -- "${TRANSER}" "${YUM2}"; then
  exit 0
else
  rpm -qipiCreate two files

TRANSFER=`rpm -qa PACKAGE_NAME >> $(hostname -s)_aspera_${TIMESTAMP}.log - on transfer host`
YUM=`rpm -qa PACKAGE_NAME >>  $(hostname -s)_aspera_${TIMESTAMP}.log - on $REPO`

if cmp --silent -- "${TRANSER}" "${YUM2}"; then
  exit 0
else
  rpm -qip
