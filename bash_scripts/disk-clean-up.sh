#!/usr/bin/env bash

# Set directory variables
dir="/n/log/$HOSTNAME"
date_now=$(date "+%F%H%M%S")

# Check if the base directory exists, create if it doesn't
if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
    echo "Directory $dir created."
else
    echo "Directory $dir already exists."
fi

# Create timestamped subdirectory, skip if already exists
log_dir="$dir/$date_now"
mkdir -p "$log_dir" || { echo "Directory creation failed"; exit 1; }

# Move log files to the timestamped directory
log_files=(
    "/var/log/*.gz"
    "/var/log/boot.log.*"
    "/var/log/consul.log-20*"
    "/var/log/cron.*"
    "/var/log/cron-*"
    "/var/log/fail2ban.log.*"
    "/var/log/falcon-sensor.log.*"
    "/var/log/maillog.*"
    "/var/log/secure.*"
    "/var/log/yum.log.*"
    "/var/log/wtmp.*"
    "/var/log/spooler.*"
    "/var/log/spooler-*"    
    "/var/log/messages.*"
    "/var/log/btmp.*"
    "/var/log/boot.*-*"
    "/var/log/dmesg.old"
    "/var/log/acc.log.*"
    "/var/log/sensu-client.log.*"
    "/var/log/sensu-client.log-*"
    "/var/log/audit/audit.log.*"
    "/var/log/harbor/*.gz"
    "/var/log/vmware-vgauthsvc.log.*"
    "/var/log/vmware-network.*"
    "/va/log/vmware-vmsvc.log"
    "/var/log/sssd/*.gz"
    "/var/log/servicenow/agent-client-collector/"
    "/var/log/metrics.log.*"
    "/var/log/health.log.*"
    "/var/log/migration.log.2024-0*"
    "/var/log/splunkd.log.*"
    "/var/log/sensu/*.gz"
    "/var/log/dmeg.*"
    "/var/log/tuned/*.gz"
    )

for file in "${log_files[@]}"; do
    mv $file "$log_dir" 2>/dev/null || echo "Failed to move $file or file does not exist"
done

# Enable CentOS 7 repositories and clean yum cache if running on CentOS
if grep -q "^ID=\"centos\"" /etc/os-release; then
    yum-config-manager --enable centos-7*
    yum clean all
else
    yum clean all
fi

# Clean up old Puppet cache
rm -rf /opt/puppetlabs/puppet/cache/clientbucket/

# Remove old kernels, keeping the latest 3
package-cleanup --oldkernels --count=3
echo " "
echo " "
df -h /
