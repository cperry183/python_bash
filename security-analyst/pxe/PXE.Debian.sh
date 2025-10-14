
#!/bin/sh
###################################################
#
#Program: Setup a PXE Server CentOS7
#
#Script Name: pxe-server.sh
#
#Developer: Chad Perry
#
#Date: 04-15-2016
#
###################################################
#
#Install DHCP Server on Ubuntu | PXE Server
#
sudo yum update && upgrade 
sudo yum install isc-dhcp-server tftpd-hpa pxelinux nfs-kernel-server initramfs-tools kickstarter -y
systemctl restart isc-dhcp-server
#
#Configure etc/default/tftpd-hpa
#/etc/default/tftpd-hpa
#Orignal text to be added to Filesystem#
#[...]
#RUN_DAEMON="yes"
#OPTIONS="-l -s /var/lib/tftpboot"
#
# Edit the /etc/default/tftpd-hpa
cat << EOM >> /etc/default/tftpd-hpa
[...]
RUN_DAEMON="yes"
OPTIONS="-l -s /var/lib/tftpboot"
EOM
#
#Restart tftpd-hpa
sysctl /tftpd-hpa restart
#
#Then edit /etc/inetd.conf
#vi /etc/inetd.conf
#Orignal text to be added to Filesystem#
#tftp    dgram   udp    wait    root    /usr/sbin/in.tftpd /usr/sbin/in.tftpd -s /var/lib/tftpboot
#
cat << EOM >> /etc/inetd.conf
tftp    dgram   udp    wait    root    /usr/sbin/in.tftpd /usr/sbin/in.tftpd -s /var/lib/tftpboot
EOM
#
#Restart tftp
#
/etc/init.d/tftpd-hpa restart
#
#Mount Image file to /mnt
#
mount -o loop /directory_where_ISO_is_Located/CentOS-7-x86_64-DVD.iso/mnt/;
cd /mnt/;
cp -fr install/netboot/* /var/lib/tftpboot/;
mkdir /var/www/html/CentOS-7-x86_64-DVD;
cp -fr /mnt/* /var/www/html/ubuntu-15/;
#
#Edit the /var/lib/tftpboot/pxelinux.cfg/default
#Add the following contents at the end. Make sure you’ve replaced the IP address with your own.
#Orignal text to be added to Filesystem#
#[...]
#label linux
#kernel ubuntu-installer/amd64/linux
#append ks=http://9.3.61.32/ks.cfg vga=normal initrd=ubuntu-installer/amd64/initrd.gz
#ramdisk_size=16432 root=/dev/rd/0 rw  --
#
cat << EOM >> /var/lib/tftpboot/pxelinux.cfg/default
[...]
label linux
kernel ubuntu-installer/amd64/linux
append ks=http://9.3.61.32/ks.cfg vga=normal initrd=ubuntu-installer/amd64/initrd.gz
ramdisk_size=16432 root=/dev/rd/0 rw  --
EOM
#
#Edit /etc/dhcp/dhcpd.conf
#vi /etc/dhcp/dhcpd.conf
#Orinal Text to add to filesystem
#allow booting
#allow bootp
#option option-128 code 128 = string
#option option-129 code 129 = text
#next-server <IPv4>
#filename "pxelinux.0"
#
cat << EOM >> /etc/dhcp/dhcpd.conf
allow booting
allow bootp
option option-128 code 128 = string
option option-129 code 129 = text
next-server <9.3.x.x>
filename "pxelinux.0"
EOM
#
#Restart DHCP Server
#
systemctl restart isc-dhcp-server
