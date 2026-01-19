#!/usr/bin/env bash 

yum update -y --disablerepo=* --enablerepo=els* --enablerepo=centos-7* --exclude=sensu --exclude=puppet-agent
yum install --disablerepo=* --enablerepo=els* --enablerepo=centos-7* -y curl policycoreutils-python openssh-server perl
for SYS in start enable; do systemctl ${SYS} sshd;done
systemctl start firewalld
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
systemctl reload firewalld
yum install postfix
systemctl enable postfix
systemctl start postfix
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash
export EXTERNAL_URL="https://$HOSTNAME";  yum install gitlab-ee


