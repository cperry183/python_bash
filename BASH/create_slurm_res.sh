
#!/usr/bin/env bash 

#####################
# update variables #
# create nodes.txt #
# ##################


# === User-editable params ===
RES_NAME="SEC_REMEDIATIONS-$1"
DAY=$(printf "%02d" $2)  
START_TIME="2025-11-${DAY}T05:00:00"
END_TIME="2025-11-${DAY}T07:00:00"
FLAGS="MAINT,IGNORE_JOBS"
USERS="root"
NODE_FILE="nodes.txt"

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
