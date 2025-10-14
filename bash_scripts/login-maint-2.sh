#!/usr/bin/env bash

# Check for root privileges
if [[ "$EUID" -ne 0 ]]; then
    echo "Please run this script as root." >&2
    exit 1
fi
# Function to bring the server down for maintenance
bring_server_down() {
    # update_motd "This host will be offline for maintenance. Please use the DNS round-robin to use another login node."
    puppet agent -t --disable 'rebooting hosts for kernel update'
    remove_consul
    sleep 2m
    nslookup o2.hms.harvard.edu | grep Address | sort -u
    for s in {21..26}; do nslookup 134.174.159.$s; done
    echo "Server is now down for maintenance." >&2
}
# Function to add the server back to the pool
add_server_to_pool() {
    puppet agent --enable     
    puppet agent -t --environment="$branch_name"
    add_consul 
    sleep 3m
    nslookup o2.hms.harvard.edu | grep Address | sort -u
    for s in {21..26}; do nslookup 134.174.159.$s; done
    echo "Server is ready for use." >&2
}
# Function to check and delete the file
check_and_delete_file() {
    local file="/etc/security/access.conf"
    if [[ -e "$file" ]]; then
        rm -f "$file"
        echo "The file $file has been deleted." >&2
    else
        echo "The file $file does not exist." >&2
    fi
}
remove_consul() {
    local action_success=true
    for action in stop disable is-active; do
        if systemctl $action consul; then
           echo "Successfully executed 'systemctl $action consul'."
        else
           echo "Failed to execute 'systemctl $action consul'." >&2
           action_success=false
        fi
    done
    if [ "$action_success" = true ]; then
        echo "Consul service has been successfully stopped and disabled." >&2
    else
        echo "There were issues removing the server back to the pool." >&2
        return 1
    fi
}
add_consul() {
    local action_success=true
    for action in start enable is-active; do
        if systemctl $action consul; then
           echo "Successfully executed 'systemctl $action consul'."
        else
           echo "Failed to execute 'systemctl $action consul'." >&2
           action_success=false
        fi
    done
    if [ "$action_success" = true ]; then
        echo "Consul service has been successfully started and enabled." >&2
    else
        echo "There were issues adding the server back to the pool." >&2
        return 1
    fi
}
# Main script
read -r -p "Do you want to bring the server down for maintenance? (Yes/No): " down_answer
if [[ "$down_answer" == "Yes" ]]; then
    bring_server_down
else
    echo "Server will not be brought down for maintenance." >&2
fi
read -r -p "Do you want to add the server back to the pool? (Yes/No): " up_answer
if [[ "$up_answer" == "Yes" ]]; then
    read -r -p "What branch? " branch_name
    if [[ -z "$branch_name" ]]; then
        echo "Branch name not provided. Aborting operation." >&2
        exit 1
    fi
    add_server_to_pool
else
    echo "Server will not be added back to the pool." >&2
fi
read -r -p "Do you want to check and delete the file /etc/security/access.conf? (Yes/No): " file_answer
if [[ "$file_answer" == "Yes" ]]; then
    check_and_delete_file
else
    echo "The file check and delete operation was skipped." >&2
fi
