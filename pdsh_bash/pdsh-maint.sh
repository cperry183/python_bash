#!/usr/bin/env bash

# Function to display an error
error() {
    echo "$1" >&2
    exit 1
}
read -p "Enter the group: " GROUP
[ -z "$GROUP" ] && error "Group is required!"
# Ask for the action choice
while true; do
    read -p "Do you want to update the kernel (y/n)? " yn_kernel
    if [[ "$yn_kernel" =~ ^[Yy] ]]; then
        ACTION="kernel"
        break
    elif [[ "$yn_kernel" =~ ^[Nn] ]]; then
        read -p "Do you want to update a package (y/n)? " yn_package
        if [[ "$yn_package" =~ ^[Yy] ]]; then
            ACTION="package"
            read -p "Enter the package name: " PACKAGE
            [ -z "$PACKAGE" ] && error "Package name is required!"
            break
        elif [[ "$yn_package" =~ ^[Nn] ]]; then
            read -p "Do you want to run a command (y/n)? " yn_cmd
            if [[ "$yn_cmd" =~ ^[Yy] ]]; then
                ACTION="command"
                read -p "Enter the command: " CMD
                [ -z "$CMD" ] && error "Command is required!"
                break
            elif [[ "$yn_cmd" =~ ^[Nn] ]]; then
                error "No valid action chosen. Exiting."
            else
                echo "Please answer yes or no."
            fi
        else
            echo "Please answer yes or no."
        fi
    else
        echo "Please answer yes or no."
    fi
done

timestamp=$(date +"%Y%m%d")
dir_path="/home/chp6694/vuln_artifacts/vul_logs_${timestamp}"
mkdir -p "$dir_path"

if [ "$ACTION" == "kernel" ]; then
    pdsh -g "$GROUP" 'yum clean all && yum update kernel-* -y --disablerepo=* --enablerepo=centos-7*'
elif [ "$ACTION" == "package" ]; then
    pdsh -g "$GROUP" "yum clean all && yum update --disablerepo=* --enablerepo=centos-7* $PACKAGE -y"
    mv "/tmp/${PACKAGE}.log" "$dir_path"
elif [ "$ACTION" == "command" ]; then
     pdsh -g "$GROUP" "bash -c '$CMD'"
fi
