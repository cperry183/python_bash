#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Exiting."
    exit 1
fi

# Define source and destination directories
SOURCE="/home/chp6694_adm"
DESTINATION="/n/cluster/chp6694/_home/_chp6694_adm/backup"

# Use rsync to copy new and updated files
rsync -av --ignore-existing "$SOURCE" "$DESTINATION"

# Optional: Print a message indicating completion
echo "Backup completed from $SOURCE to $DESTINATION."

 
########################
# Delete Hidden Files  #
########################
 
# Define a variable for hidden files
HIDDEN_FILES=".*"

# Prompt for confirmation
read -p "Are you sure you want to delete all unnecessary hidden files (.*) in the current directory? (y/n): " confirmation

if [[ "$confirmation" =~ ^[Yy]$ ]]; then
    # Delete hidden files, excluding the special directories "." and ".."
    find . -maxdepth 1 -name "$HIDDEN_FILES" ! -name '.' ! -name '..' -exec rm -rf {} +

    echo "Unnecessary hidden files deleted."
else
    echo "Operation canceled."
fi
