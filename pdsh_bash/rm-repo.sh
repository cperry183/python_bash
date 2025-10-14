#!/usr/bin/env bash
set -x

if [ $EUID -ne 0 ]; 
then
    echo "This script must be run as root"
    exit 1
fi

export LOGDIR="$(mktemp -d -p /home/chp6694_adm/logfiles/)"
trap 'rm -rf -- "$LOGDIR"' EXIT

if [ ! -f /etc/dsh/group/"$1" ]; then
    echo "The specified file /etc/dsh/group/$1 does not exist."
    exit 1
fi

cp -Rf /etc/dsh/group/"$1" /tmp/all_kernel

if [ ! -f /tmp/all_kernel ]; then
    echo "Failed to copy /etc/dsh/group/$1 to /tmp/all_kernel."
    exit 1
fi

for DIRE in 1 2; do
  touch "${LOGDIR}/output0${DIRE}"
done

cat /tmp/all_kernel | sort -u | sed 's/://g' | awk '{print $1}' | xargs -I % pdsh -w % 'rm -rf /etc/yum.repos.d/'"${2}.repo" >> "${LOGDIR}/output01"
cat /tmp/all_kernel | sort -u | sed 's/://g' | awk '{print $1}' | xargs -I % pdsh -w % 'ls /etc/yum.repos.d/ | grep -e '"${2}"' ; echo $?' >> "${LOGDIR}/output02"

if ! grep -q "CentOS-x86_64-kernel" "$LOGDIR/output02"; then
    echo "The CentOS-x86_64-kernel.repo was successfully removed from all nodes."
elif grep -q "CentOS-x86_64-kernel" "$LOGDIR/output02"; then
    echo "The CentOS-x86_64-kernel.repo still exists on some nodes."
else
    echo "An unexpected error occurred."
fi
