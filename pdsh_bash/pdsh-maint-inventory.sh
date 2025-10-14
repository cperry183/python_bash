#!/bin/bash
# Function to display an error message and exit
error() {
    echo "$1" >&2
    exit 1
}
# Prompt for group, continue without group if not provided
read -p "Enter the group (leave empty to use custom inventory): " GROUP
# Set the default action to none
ACTION="none"
# Loop until a valid action is chosen or the user exits
while true; do
    read -p "Do you want to update the kernel (y/n)? " yn_kernel
    if [[ "$yn_kernel" =~ ^[Yy] ]]; then
        ACTION="kernel"
        break
    elif [[ "$yn_kernel" =~ ^[Nn] ]]; then
        if [ -z "$GROUP" ]; then
            ACTION="custom_inventory"
            break
        else
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
        fi
    else
        echo "Please answer yes or no."
    fi
done
# Set the directory path with a timestamp
timestamp=$(date +"%Y%m%d")
dir_path="/home/chp6694/vuln_artifacts/vul_logs_${timestamp}"
mkdir -p "$dir_path"
# Perform actions based on the user's choice
if [ "$ACTION" == "kernel" ]; then
    pdsh -g "$GROUP" 'yum clean all && yum update kernel-* -y --disablerepo=* --enablerepo=centos-7*'
elif [ "$ACTION" == "package" ]; then
    pdsh -g "$GROUP" "yum clean all && yum update --disablerepo=* --enablerepo=centos-7* $PACKAGE -y"
    mv "/tmp/${PACKAGE}.log" "$dir_path"
elif [ "$ACTION" == "command" ]; then
    pdsh -g "$GROUP" "bash -c '$CMD'"
elif [ "$ACTION" == "custom_inventory" ]; then
    read -p "Define the inventory name: " INVENTORY
    [ -z "$INVENTORY" ] && error "Inventory name is required!"
    read -p "Enter the command to run: " CMD
    [ -z "$CMD" ] && error "Command is required!"
    cat "/tmp/${INVENTORY}.txt" | sort -u | sed 's/://g' | awk '{print $1}' | xargs -I % pdsh -w % "bash -c '${CMD}'"
fi










