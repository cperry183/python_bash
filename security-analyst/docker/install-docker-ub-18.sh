#!/bin/bash

# Install docker for Ubuntu 18.04

sudo apt-get update -y; 

sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common -y 
    
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    
sudo add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"

sudo apt-get update -y 

sudo apt-get install docker-ce -y 

# clean up if necessary 
sudo apt autoremove -y 

sudo docker run hello-world 
