#!/usr/bin/env bash
# Function to display an error
error() {
    echo "$1" >&2
    exit 1
}
# Pull the group from the home directory
GROUP=$(basename $HOME)
echo "Group pulled from home directory: $GROUP"
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
dir_path="$HOME/vuln_artifacts/vul_logs_${timestamp}"
mkdir -p "$dir_path"
if [ "$ACTION" == "kernel" ]; then
    pdsh -g "$GROUP" 'yum clean all && yum update kernel -y'
elif [ "$ACTION" == "package" ]; then
    pdsh -g "$GROUP" "yum clean all && yum update --disablerepo=* --enablerepo=centos-7* $PACKAGE -y"
    mv "/tmp/${PACKAGE}.log" "$dir_path"
elif [ "$ACTION" == "command" ]; then
     pdsh -g "$GROUP" "bash -c '$CMD'"
fi
6:35 PM
chad_p
 #!/usr/bin/env bash
# Function to display an error
error() {
    echo "$1" >&2
    exit 1
}
# Set the PDSH environment variables to use genders file in $HOME
export PDSH_RCMD_TYPE=genders
export WCOLL=~/genders
# List all groups defined in the genders file in $HOME
GROUPS=( $(awk '{print $2}' ~/genders | cut -d= -f2 | sort -u) )
# Check if any groups were found
if [ ${#GROUPS[@]} -eq 0 ]; then
    echo "No groups found in $HOME/genders!"
    exit 1
fi
# Display the groups and prompt the user to select one
echo "Available groups:"
for i in "${!GROUPS[@]}"; do
    echo "$((i+1)). ${GROUPS[$i]}"
done
while true; do
    read -p "Select a group by number: " SELECTION
    if [ "$SELECTION" -ge 1 ] && [ "$SELECTION" -le ${#GROUPS[@]} ]; then
        GROUP="${GROUPS[$((SELECTION-1))]}"
        echo "Selected group: $GROUP"
        break
    else
        echo "Invalid selection. Please select a number from the list."
    fi
done
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
dir_path="$HOME/vuln_artifacts/vul_logs_${timestamp}"
mkdir -p "$dir_path"
if [ "$ACTION" == "kernel" ]; then
    pdsh -g "$GROUP" 'yum clean all && yum update kernel -y'
elif [ "$ACTION" == "package" ]; then
    pdsh -g "$GROUP" "yum clean all && yum update --disablerepo=* --enablerepo=centos-7* $PACKAGE -y"
    mv "/tmp/${PACKAGE}.log" "$dir_path"
elif [ "$ACTION" == "command" ]; then
     pdsh -g "$GROUP" "bash -c '$CMD'"
fi
