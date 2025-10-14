#!/bin/bash

###################################################
#	 Program: Installation of Samba
#	 Developer: Chad Perry
#  Date: 05-02-2016
# ******************************************
#
#Installation of the Samba Package
#
sudo apt-get -y update -y
sudo apt-get -y install samba -y
#
#Edit the configuration file (/etc/samba/smb.conf)
workgroup = ibm.com
security = user
#
#Adding Configuration for a Samba Server
#
cat << EOM >> etc/samba/smb.conf
[share]
    comment = <Comment about the Folder>
    path = /srv/samba/<Folder Name>
    available = yes
    valid users = <Users to access Samba>
    read only = no
    browsable = yes
    public = yes
    writable = yes
    create mask = 0775
    guest ok = yes
EOM
#
#Create this Directory for Share files
mkdir -p /srv/samba/<Directory Name of your Choosing>
chown nobody:nogroup /srv/samba/share/
#
#Change Permission to Allow all to Read/write/
#
sudo chmod -R 777 /srv/samba/share/
#
#Restarting Services
#
sudo smbpasswd -a <username> #Adding a User to Samba Account
service restart smbd
service restart nmbd
#
#To Login into From MacBook
#Enable File Sharing
#Finder > Go > Connect to Server
#cifs://<9.3.x.x>/share
