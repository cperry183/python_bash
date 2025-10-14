#!/usr/bin/env bash

# Test if Nvidia drivers are installed using dkms.  If dksm is not
# installed, install it If the nvidia driver is not register with
# dksm, uninstall nvidia and rerun puppet to install it and hopefully
# register it with dkms

#Puppet return codes:
# 0: The run succeeded with no changes or failures; the system was already in the desired state.
# 1: The run failed, or wasn't attempted due to another run already in progress.
# 2: The run succeeded, and some resources were changed.

# I canz has nvidia-smi?
DKMS=/usr/sbin/dkms
DKMS_INSTALLED=false
NVIDIA_INSTALLED=false
NVIDIA_SMI=/usr/bin/nvidia-smi

# is nvidia installed:
if [[ -f "$NVIDIA_SMI" ]]; then
    echo "$NVIDIA_SMI exists."
    NVIDIA_INSTALLED=true
    echo $NVIDIA_INSTALLED
else
    echo "NVIDIA Driver: $NVIDIA_INSTALLED"
#    exit 0
fi


# if nvidia, check for dkms, install if needed.
if [[ $NVIDIA_INSTALLED == true ]]; then
    # Is dkms installed?
    if [[ -f "$DKMS" ]]; then
	# echo "$DKMS exists."
	DKMS_INSTALLED=true
    else
	/usr/bin/yum install dkms  --enablerepo=centos-7* -y
	if !  [[ $? -eq 0 ]]; then
	    echo "Hey Friend, yum failed to install dkms, I need help over here!"
	    exit 1
	fi
	DKMS_INSTALLED=true
    fi
fi

# now that we know that this node needs both nvidia install and dkms,
# check if the nvidia driver is register with dkms.
if [[ $DKMS_INSTALLED=true ]]; then
    if [[ $(dkms status |grep -c nvidia) -eq 1 ]]; then
	# nvidia is not registered with dksm, uninstall and reinstall
	/usr/bin/nvidia-uninstall -q -s 
	if [[ $? -ne 0 ]]; then
            echo "Hey Buddy, failed to remove the nvidia driver, I need help over here!"
            exit 1
	fi
	# run puppet to reinstall nvidia, and if it's a new puppet branch it will install nvidia with dkms
	/opt/puppetlabs/bin/puppet agent -t
	if [[ $? -ne 2 ]]; then
            echo "Hey Pal, puppet failed when trying to install Nvidia, I need a pair of eyeballs over here!"x
            exit 1
        fi
    fi

    if [[ $(dkms status |grep -c nvidia) -gt 0 ]]; then
	echo "Nvidia installed with DKMS"
    elif [[ $(dkms status |grep -c nvidia) -eq 0 ]]; then
	echo "Hey Guy, Nvidia NOT installed with DKMS, or some other problem and you need to look at $(hostname -s)"
    fi
fi
