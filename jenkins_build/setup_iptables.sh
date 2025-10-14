#!/usr/bin/env bash 
set -x 

sudo iptables -A -P INPUT ACCEPT
sudo iptables -A INPUT -p tcp -m multiport --dports 80 -m comment --comment "000 allow 80" -j ACCEPT
sudo iptables -A INPUT -p tcp -m multiport --dports 22 -m comment --comment "000 allow SSH" -j ACCEPT
sudo iptables -A INPUT -s 10.120.6.123/32 -p tcp -m multiport --dports 8000 -m comment --comment "000 allow tenable_proxy" -j ACCEPT
sudo iptables -A INPUT -p tcp -m multiport --dports 80,443 -m comment --comment "000 allow web" -j ACCEPT
sudo iptables -A INPUT -p tcp -m multiport --dports 8301 -m comment --comment "001 allow consul agent gossip tcp" -j ACCEPT
sudo iptables -A INPUT -p udp -m multiport --dports 8301 -m comment --comment "001 allow consul agent gossip udp" -j ACCEPT
sudo iptables -A INPUT -p tcp -m multiport --dports 8080 -m state --state NEW -m comment --comment "500 allow Jenkins inbound traffic" -j ACCEPT
sudo iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -p icmp -j ACCEPT
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
