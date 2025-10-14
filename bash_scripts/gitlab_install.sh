#!/usr/bin/env bash 

yum update -y 
yum install -y curl policycoreutils-python openssh-server perl
systemctl enable sshd
systemctl start sshd
systemctl start firewalld
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
systemctl reload firewalld
yum install postfix
systemctl enable postfix
systemctl start postfix
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash
EXTERNAL_URL="https://$HOSTNAME";  yum install -y gitlab-ee

