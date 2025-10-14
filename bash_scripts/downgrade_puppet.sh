#!/usr/bin/env bash 

yum downgrade puppet-agent-6.18.0
yum install yum-plugin-versionlock -y 
yum versionlock puppet-agent
systemctl restart puppet
systemctl status puppet 
