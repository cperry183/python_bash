#!/bin/bash 
############################################
#	 Script Name: Anisible.sh
# 	 Developer: Chad Perry
# 	 Date: 04-19-2016
# 	 Last Updated: 04-19-2016
###########################################
#
#
#http://docs.ansible.com/ansible/intro_getting_started.html
#
#
#Installation of Necessary Packages
apt-get update -y
apt-get install openssh-server git make -y
git clone git://github.com/ansible/ansible.git --recursive
cd ./ansible
apt-get -y update
#
#Installation of Easy Install and PIP Dependencies
apt-get install python-setuptools -y
easy_install pip -y
pip install paramiko PyYAML Jinja2 httplib2 six
#
#Updating Ansible
git pull --rebase
git submodule update --init --recursive
#
#Updates for Debian OS
sudo apt-get install python-software-properties -y
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update -y
sudo apt-get install ansible-y

cat << EOM >> /etc/ansible/hosts
echo "127.0.0.1" > ~/ansible_host
export ANSIBLE_INVENTORY=~/ansible_host
