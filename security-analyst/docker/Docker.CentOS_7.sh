#!/bin/bash

#Installation of Docker
#CentOS 7
#https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-centos-7

#Installation of Docker
sudo yum check-update -y #Update package Database
sudo yum update -y
curl -fsSL https://get.docker.com/ | sh
sudo systemctl start docker
sudo systemctl status docker
sudo systemctl enable docker

Enabling Docker with Sudo
sudo usermod -aG docker $(whoami)

#sudo usermod -aG docker <username>#Adding a user to docker#
#docker# View Docker command#

cd cd /var/run/docker/libcontainerd/
rm -rf docker-containerd.pid

#Testing Docker
docker run hello-world

#Find the OS that you want to user
docker search centos

#Download the OS and install
docker pull centos
#docker images
#docker run -it centos
#docker #View all commands
