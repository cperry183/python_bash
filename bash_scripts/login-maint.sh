#!/bin/bash

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi
# Function to bring the server down for maintenance
bring_server_down() {
#    update_motd "This host will be offline for maintenance. Please use the DNS round-robin to use another login node."
    puppet agent -t --disable 'rebooting hosts for kernel update'
    systemctl stop puppet
    systemctl stop  consul
    systemctl disable consul
    sleep 2m
    nslookup o2.hms.harvard.edu | grep Address | sort -u
    for s in 21 22 23 24 25 26; do nslookup 134.174.159.${s}; done
    echo "Server is now down for maintenance."
}
# Function to add the server back to the pool
add_server_to_pool() {
     puppet agent -t --enable 
     puppet agent -t --environment=$branch_name     
     systemctl start consul
     systemctl enable consul
     systemctl status consul 
     sleep 2m
     nslookup o2.hms.harvard.edu | grep Address | sort -u
     for s in 21 22 23 24 25 26; do nslookup 134.174.159.${s}; done
}
# Function to check and delete the file
check_and_delete_file() {
    local file="/etc/security/access.conf"
    if [[ -e "$file" ]]; then
        rm -rf "$file"
        echo "The file $file has been deleted."
    else
        echo "The file $file does not exist."
    fi
}
# Main script
read -r -p "Do you want to bring the server down for maintenance? (Yes/No): " down_answer
if [ "$down_answer" == "Yes" ]; then
    bring_server_down
else
    echo "Server will not be brought down for maintenance."
fi
read -r -p "Do you want to add the server back to the pool? (Yes/No): " up_answer
if [ "$up_answer" == "Yes" ]; then
    read -r -p "What branch? " branch_name
    echo "Server will be added back to the pool for branch: $branch_name"
    add_server_to_pool
else
    echo "Server will not be added back to the pool."
fi
read -r -p "Do you want to check and delete the file /etc/security/access.conf? (Yes/No): " file_answer
if [ "$file_answer" == "Yes" ]; then
    check_and_delete_file
else
    echo "The file check and delete operation was skipped."
fi
