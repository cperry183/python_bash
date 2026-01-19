#!/usr/bin/env bash

INVENTORY="$1"

if [[ ! -f "$INVENTORY" ]]; then
    echo "Error: Inventory file '$INVENTORY' does not exist."
    exit 1
fi

while IFS= read -r NODE || [[ -n "$NODE" ]]; do
    [[ -z "$NODE" || "$NODE" =~ ^# ]] && continue

    echo "🔧 Cleaning cert for: $NODE"
    
    OUTPUT=$(puppetserver ca clean --certname "$NODE" 2>&1)
    STATUS=$?

    echo "$OUTPUT"

    if [[ $STATUS -ne 0 ]]; then
        echo "❌ Failed to clean cert for $NODE"
    else
        echo "✅ Successfully cleaned cert for $NODE"
    fi

    echo "----------------------------------------"
done < "$INVENTORY"