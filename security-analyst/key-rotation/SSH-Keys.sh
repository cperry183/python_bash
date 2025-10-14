#!/usr/bin/env bash

USER=USER_DEFINED
sudo yum install vim curl wget -y 
mkdir /home/$USER/.ssh
cat << EOF >> /home/arl/.ssh/authorized_keys
ssh-rsa <KEYS>
EOF
