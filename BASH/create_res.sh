scontrol create reservation ReservationName=SEC_REMEDIATIONS-17 StartTime=2025-02-22T05:00:00 EndTime=2025-02-22T07:00:00 Flags=MAINT,IGNORE_JOBS Users=root Nodes=compute-h-17-54,compute-g-17-153,compute-a-16-68,compute-a-16-107,compute-a-17-110, compute-a-16-79,compute-a-16-170



#!/bin/bash

# === User-editable params ===
RES_NAME="SEC_REMEDIATIONS-17"
START_TIME="2025-02-22T05:00:00"
END_TIME="2025-02-22T07:00:00"
FLAGS="MAINT,IGNORE_JOBS"
USERS="root"
NODE_FILE="nodes.txt"   # <-- CHANGE THIS if your node file has a different name

# === Check node file exists ===
if [[ ! -f "$NODE_FILE" ]]; then
    echo "Node file '$NODE_FILE' not found!"
    exit 1
fi

# === Read and format nodelist ===
NODELIST=$(paste -sd, "$NODE_FILE" | tr -d '[:space:]')

# === Build the scontrol command ===
CMD="scontrol create reservation ReservationName=$RES_NAME StartTime=$START_TIME EndTime=$END_TIME Flags=$FLAGS Users=$USERS Nodes=$NODELIST"

echo "Running: $CMD"
eval $CMD

# End