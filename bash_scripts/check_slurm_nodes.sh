#!/usr/bin/env bash

##########################################
# Author:         Chad Perry
# Date:           February 25, 2025
# Name:           check_slurm_nodes.sh
# Revision:       v1.2.2
# Description:    Checks SLURM nodes status and identifies decommissioned nodes
##########################################

set -euo pipefail  # Exit on error, unset var, or failed pipeline

# --- Constants ---
readonly REPORT_DIR="/home/chp6694_adm/Slurm_Reports/slurm_nodes_reports"
readonly TIME=$(date +"%Y%m%d_%H%M%S")
readonly ARCHIVE="${REPORT_DIR}/${TIME}"
readonly INPUT_FILE_PATH="${REPORT_DIR}/slurm_nodes_${TIME}.txt"
readonly DECOM_FILE_PATH="${REPORT_DIR}/decom_nodes_${TIME}.txt"
readonly LOG_FILE="${REPORT_DIR}/check_slurm_nodes_${TIME}.log"
readonly SCHEDULE_JSON="/n/cluster/etc/maintenance/prod/schedule.json"

# --- Log function ---
log_message() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# --- File existence/readability check function ---
check_file() {
    if [[ ! -f "$1" || ! -r "$1" ]]; then
        log_message "ERROR: File $1 does not exist or is not readable"
        exit 1
    fi
}

main() {
    # Create report and archive directories
    mkdir -p "$REPORT_DIR" || {
        echo "Failed to create report directory" >&2
        exit 1
    }
    mkdir -p "$ARCHIVE" || {
        echo "Failed to create archive directory" >&2
        exit 1
    }

    # Initialize log file
    touch "$LOG_FILE" || {
        echo "Failed to create log file" >&2
        exit 1
    }
    log_message "Starting SLURM nodes check"

    # Check maintenance schedule file
    check_file "$SCHEDULE_JSON"

    # 1. Extract and filter node names
    log_message "Extracting node names from schedule.json"
    sed -n 's/[" ,]//g; s/^.*\(compute-[a-z]-[0-9]\{2\}-[0-9]\+\).*$/\1/p' "$SCHEDULE_JSON" |
        awk -F'-' '{if ($4 > 44) print $0}' > "$INPUT_FILE_PATH" || {
            log_message "ERROR: Failed to process node names"
            exit 1
        }

    # 2. Count valid compute-* nodes, excluding blanks
    NODE_COUNT=$(grep -E '^compute-' "$INPUT_FILE_PATH" | sed '/^[[:space:]]*$/d' | wc -l)
    log_message "Total compute-* nodes listed (excluding whitespace): $NODE_COUNT"

    # 3. Process nodes if any found
    if [[ -f "$INPUT_FILE_PATH" && -s "$INPUT_FILE_PATH" ]]; then
        log_message "Processing nodes from $INPUT_FILE_PATH"

        # Initialize/decommission file
        > "$DECOM_FILE_PATH"

        while IFS= read -r node || [[ -n "$node" ]]; do
            [[ -z "$node" ]] && continue  # Skip empty lines

            log_message "Checking node: $node"

            # Don't let set -e exit script on scontrol error
            OUTPUT="$(scontrol show nodes "$node" 2>&1 || true)"

            if echo "$OUTPUT" | grep -iq "not found"; then
                log_message "Node $node marked for decommissioning - not found in SLURM"
                echo "$node" >> "$DECOM_FILE_PATH"
            fi
        done < "$INPUT_FILE_PATH"

        # Archive input and decommission reports
        log_message "Archiving reports"
        mv "$INPUT_FILE_PATH" "$ARCHIVE/" && mv "$DECOM_FILE_PATH" "$ARCHIVE/" || {
            log_message "ERROR: Failed to archive files"
            exit 1
        }

        log_message "Completed successfully"
    else
        log_message "ERROR: Input file $INPUT_FILE_PATH is empty or doesn't exist"
        exit 1
    fi
}

# Trap errors and cleanup
trap 'log_message "ERROR: Script terminated unexpectedly"; exit 1' ERR

main
