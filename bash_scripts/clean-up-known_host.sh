#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 /path/to/inventory.txt"
    exit 1
fi

INVENTORY="$1"

if [[ ! -f "$INVENTORY" ]]; then
    echo "Error: Inventory file '$INVENTORY' does not exist."
    exit 1
fi

while IFS= read -r NODE || [[ -n "$NODE" ]]; do
    # Skip empty lines or comments
    [[ -z "$NODE" || "$NODE" =~ ^# ]] && continue

    echo "🔧 Cleaning system-wide known_hosts entry for: $NODE"

    OUTPUT=$(sudo ssh-keygen -R "$NODE" -f /etc/ssh/ssh_known_hosts 2>&1)
    STATUS=$?

    echo "$OUTPUT"

    if [[ $STATUS -ne 0 ]]; then
        echo "❌ Failed to clean known_hosts for $NODE"
    else
        echo "✅ Successfully cleaned known_hosts for $NODE"
    fi

    echo "----------------------------------------"

done < "$INVENTORY"
