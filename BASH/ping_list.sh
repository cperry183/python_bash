#!/bin/bash

# File containing the list of nodes (one node per line)
NODE_LIST="nodes.txt"

# Output file for results
OUTPUT_FILE="ping_results.txt"

# Check if the node list file exists
if [[ ! -f $NODE_LIST ]]; then
  echo "Error: File '$NODE_LIST' not found!"
  exit 1
fi

# Clear previous output
> "$OUTPUT_FILE"

# Loop through each node in the list
while IFS= read -r node; do
  if [[ -n $node ]]; then
    echo "Pinging $node..."
    # Ping the node and check its status
    if ping -c 1 -W 1 "$node" &> /dev/null; then
      echo "$node is reachable" | tee -a "$OUTPUT_FILE"
    else
      echo "$node is unreachable" | tee -a "$OUTPUT_FILE"
    fi
  fi
done < "$NODE_LIST"

echo "Ping results saved to '$OUTPUT_FILE'."

