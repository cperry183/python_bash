#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to install convert2rhel package
install_convert2rhel() {
    echo "Installing convert2rhel..."
    yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm >/dev/null 2>&1
    yum install -y https://download.redhat.com/redhat/rhel/rhel-6-server/rhscl/1/x86_64/convert2rhel/2.0.0/convert2rhel-2.0.0-1.el6.noarch.rpm >/dev/null 2>&1
    echo "convert2rhel installed successfully."
}

# Function to register the system
register_system() {
    echo "Registering the system..."
    source rhel-creds.conf
    subscription-manager register --username="$username" --password="$password" --auto-attach >/dev/null 2>&1
    echo "System registered successfully."
}

# Function to convert the system to RHEL
convert_to_rhel() {
    echo "Converting to RHEL..."
    echo "yes" | convert2rhel --assumeyes --no-rpm-va >/dev/null 2>&1
    echo "Conversion to RHEL completed."
}

# Main function to orchestrate the conversion
main() {
    install_convert2rhel
    register_system
    convert_to_rhel
    echo "Conversion complete. Please verify the system's integrity and functionality."
}

# Call the main function
main
