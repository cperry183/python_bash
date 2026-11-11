#!/usr/bin/env bash
#
# Script to encrypt a file using ansible-vault
# Usage: ./ansible-vault-encrypt-file.sh [options] FILE
#

set -euo pipefail

# Default values
FILE_PATH=""
VAULT_ID=""
VAULT_PASSWORD_FILE=""
BACKUP=true
OUTPUT_FILE=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    cat << EOF
Usage: $0 [OPTIONS] FILE

Encrypt a file using ansible-vault (e.g., SSH keys, certificates, etc.)

OPTIONS:
    -f, --vault-password-file   Path to vault password file
    -i, --vault-id ID           Vault ID to use (e.g., prod@/path/to/password)
    -o, --output FILE           Output file (default: encrypts in place)
    -n, --no-backup             Don't create backup of original file
    -h, --help                  Show this help message

ARGUMENTS:
    FILE                        Path to file to encrypt

EXAMPLES:
    # Encrypt SSH key in place (creates backup)
    $0 ~/.ssh/id_rsa

    # Use vault password file
    $0 -f ~/.vault_pass ~/.ssh/id_rsa

    # Encrypt to a different file
    $0 -o encrypted_key ~/.ssh/id_rsa

    # No backup (dangerous!)
    $0 -n ~/.ssh/id_rsa

    # Use vault ID
    $0 -i prod@~/.vault_pass ~/.ssh/id_rsa

NOTES:
    - By default, creates a backup with .backup extension
    - The file will be encrypted in place unless -o is specified
    - To decrypt: ansible-vault decrypt FILE

EOF
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--vault-password-file)
            VAULT_PASSWORD_FILE="$2"
            shift 2
            ;;
        -i|--vault-id)
            VAULT_ID="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -n|--no-backup)
            BACKUP=false
            shift
            ;;
        -h|--help)
            usage
            ;;
        -*)
            echo -e "${RED}Error: Unknown option: $1${NC}"
            usage
            ;;
        *)
            FILE_PATH="$1"
            shift
            ;;
    esac
done

# Check if ansible-vault is available
if ! command -v ansible-vault &> /dev/null; then
    echo -e "${RED}Error: ansible-vault command not found. Please install ansible.${NC}"
    exit 1
fi

# Validate file path
if [[ -z "$FILE_PATH" ]]; then
    echo -e "${RED}Error: File path is required${NC}"
    usage
fi

if [[ ! -f "$FILE_PATH" ]]; then
    echo -e "${RED}Error: File not found: $FILE_PATH${NC}"
    exit 1
fi

# Check if file is already encrypted
if head -1 "$FILE_PATH" | grep -q '^\$ANSIBLE_VAULT'; then
    echo -e "${YELLOW}Warning: File appears to already be encrypted with ansible-vault${NC}"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Create backup if requested and encrypting in place
if [[ "$BACKUP" == true ]] && [[ -z "$OUTPUT_FILE" ]]; then
    BACKUP_FILE="${FILE_PATH}.backup"
    echo -e "${YELLOW}Creating backup: $BACKUP_FILE${NC}"
    cp "$FILE_PATH" "$BACKUP_FILE"
fi

# Build ansible-vault command
VAULT_CMD="ansible-vault encrypt"

if [[ -n "$VAULT_PASSWORD_FILE" ]]; then
    if [[ ! -f "$VAULT_PASSWORD_FILE" ]]; then
        echo -e "${RED}Error: Vault password file not found: $VAULT_PASSWORD_FILE${NC}"
        exit 1
    fi
    VAULT_CMD="$VAULT_CMD --vault-password-file=$VAULT_PASSWORD_FILE"
elif [[ -n "$VAULT_ID" ]]; then
    VAULT_CMD="$VAULT_CMD --vault-id=$VAULT_ID"
fi

if [[ -n "$OUTPUT_FILE" ]]; then
    VAULT_CMD="$VAULT_CMD --output=$OUTPUT_FILE"
fi

# Encrypt the file
echo -e "${GREEN}Encrypting file: $FILE_PATH${NC}"

if $VAULT_CMD "$FILE_PATH"; then
    echo ""
    echo -e "${GREEN}✓ Encryption complete!${NC}"

    if [[ -n "$OUTPUT_FILE" ]]; then
        echo -e "Encrypted file saved to: ${GREEN}$OUTPUT_FILE${NC}"
        echo -e "Original file unchanged: ${GREEN}$FILE_PATH${NC}"
    else
        echo -e "File encrypted in place: ${GREEN}$FILE_PATH${NC}"
        if [[ "$BACKUP" == true ]]; then
            echo -e "Backup saved to: ${YELLOW}${FILE_PATH}.backup${NC}"
        fi
    fi

    echo ""
    echo -e "${YELLOW}To decrypt:${NC}"
    if [[ -n "$VAULT_PASSWORD_FILE" ]]; then
        echo "  ansible-vault decrypt --vault-password-file=$VAULT_PASSWORD_FILE $FILE_PATH"
    elif [[ -n "$VAULT_ID" ]]; then
        echo "  ansible-vault decrypt --vault-id=$VAULT_ID $FILE_PATH"
    else
        echo "  ansible-vault decrypt $FILE_PATH"
    fi
else
    echo -e "${RED}✗ Encryption failed!${NC}"

    # Restore from backup if it exists
    if [[ "$BACKUP" == true ]] && [[ -f "${FILE_PATH}.backup" ]]; then
        echo -e "${YELLOW}Restoring from backup...${NC}"
        mv "${FILE_PATH}.backup" "$FILE_PATH"
    fi

    exit 1
fi
