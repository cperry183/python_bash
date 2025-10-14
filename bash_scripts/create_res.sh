#!/usr/bin/env bash

# === User-editable params ===
RES_NAME="RESERVATION_NAME-$1"
DAY=$(printf "%02d" "$((10#$2))")
START_TIME="2025-11-${DAY}T05:00:00"
END_TIME="2025-11-${DAY}T07:00:00"
FLAGS="MAINT,IGNORE_JOBS"
USERS="root"
NODE_FILE="nodes.txt"

# === Check args ===
if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: $0 <reservation_suffix> <day>"
    exit 1
fi

# === Validate node file ===
if [[ ! -s "$NODE_FILE" ]]; then
    echo "Error: '$NODE_FILE' missing or empty!"
    exit 1
fi

# === Read and format nodelist ===
NODELIST=$(paste -sd, "$NODE_FILE" | tr -d '[:space:]')

# === Build the scontrol command ===
CMD="scontrol create reservation ReservationName=$RES_NAME StartTime=$START_TIME EndTime=$END_TIME Flags=$FLAGS Users=$USERS Nodes=$NODELIST"

# === Logging ===
LOGFILE="reservation_${RES_NAME}.log"
echo "Running: $CMD" | tee "$LOGFILE"

# === Execute ===
eval $CMD | tee -a "$LOGFILE"
