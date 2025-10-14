#!/usr/bin/env bash 
FILE="$1"
hth to the servers.txt file
SERVERS_TXT="$HOME/$FILE.txt"

# Path to the genders file to be created
GENDERS_FILE="$HOME/genders"

# Check if the servers.txt file exists
if [[ ! -f $SERVERS_TXT ]]; then
    echo "The servers.txt file does not exist in $HOME."
    exit 1
fi

# Create or clear the genders file
$GENDERS_FILE

# Process each server in servers.txt and append to genders
while IFS= read -r server; do
    if [[ $server == dev-* ]]; then
        echo "$server group=development" >> $GENDERS_FILE
    elif [[ $server == prod-* ]]; then
        echo "$server group=production" >> $GENDERS_FILE
    else
        echo "$server group=unknown" >> $GENDERS_FILE
    fi
done < $SERVERS_TXT
echo "Genders file created at $GENDERS_FILE"
