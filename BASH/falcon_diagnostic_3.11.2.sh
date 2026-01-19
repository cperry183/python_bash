#!/bin/sh
# Linux Diagnostic Script
# Expects to be run as root
# Sensor diagnostic information
# Copyright (c) CrowdStrike, Inc. 2022-2024. All rights reserved.

set -u

unobtrusive=
enable_sysrq=
daemonset=

version_3_9_2='version 3.9.2'     && version_3_9_2_date='March 20, 2022'
version_3_9_3='version 3.9.3'     && version_3_9_3_date='April 7, 2022'
version_3_9_4='version 3.9.4'     && version_3_9_4_date='April 28, 2022'
version_3_9_5='version 3.9.5'     && version_3_9_5_date='April 29, 2022'
version_3_9_6='version 3.9.6'     && version_3_9_6_date='July 13, 2022'
version_3_9_7='version 3.9.7'     && version_3_9_7_date='July 27, 2022'
version_3_9_8='version 3.9.8'     && version_3_9_8_date='April 13, 2023'
version_3_10_0='version 3.10.0'   && version_3_10_0_date='April 24, 2023'
version_3_10_1='version 3.10.1'   && version_3_10_1_date='May 5, 2023'
version_3_10_2='version 3.10.2'   && version_3_10_2_date='July 25, 2023'
version_3_10_3='version 3.10.3'   && version_3_10_3_date='August 18, 2023'
version_3_11_0='version 3.11.0'   && version_3_11_0_date='August 18, 2023'
version_3_11_1='version 3.11.1'   && version_3_11_1_date='November 28, 2023'
version_3_11_2='version 3.11.2'   && version_3_11_2_date='October 25, 2024'
version_current=${version_3_11_2} && version_current_date=${version_3_11_2_date}

progname="${0##*/}"

display_changes() {
    cat <<EOD
Changes introduced with ${version_3_9_2} (${version_3_9_2_date}):
    - Renamed diagnostic output file extension from .xz to .bzip, to better reflect it's content.
    - Remove subdirectory used to collect diagnostic information

Changes introduced with ${version_3_9_3} (${version_3_9_3_date}):
    - Added support for -s|-show-change-log flags, to show version change log
    - By default now, sysrq IS NOT used to collect task state and blocked tasks in messages/syslog
    - Added support for the --enable-sysrq flag, to cause sysrq to collect task state and blocked tasks in messages/syslog

Changes introduced with ${version_3_9_4} (${version_3_9_4_date}):
    - Added support for 'mokutil --sb-state', to show SecureBoot state
    - Added support for 'grep -i CrowdStrike /proc/keys', to show CrowdStrike keys installed

Changes introduced with ${version_3_9_5} (${version_3_9_5_date}):
    - Added support for 'ls -lRh /var/crash/', to show kernel and user process crash/core dumps
    - Added support for 'ls -l /lib/modules/\`uname -r\`/extra', to show which sensor KMODs have been written to disk. This can be useful for diagnosing errors occuring when the sensor is starting up
    - Added support for 'dpkg-query -l', to show packages installed on an Ubuntu system
    - Added support for 'rpm -qa', to show packages installed for distros supporting RPM
    - Changed deprecated 'dpkg -g' to 'dpkg -s'
    - Log falcon_diagnostic.sh version to extended/falcon_diagnostic-version.txt

Changes introduced with ${version_3_9_6} (${version_3_9_6_date}):
    - Collect libbpf log, if present

Changes introduced with ${version_3_9_7} (${version_3_9_7_date}):
    - Added support for KM Sensor as DaemonSet(KMSD)

Changes introduced with ${version_3_9_8} (${version_3_9_8_date}):
    - Renamed diagnostic output file extension from .bzip to .xz to support a wider range of tools.

Changes introduced with ${version_3_10_0} (${version_3_10_0_date}):
    - Added support for falcon-sensor-bpf and to query sensor backend.

Changes introduced with ${version_3_10_1} (${version_3_10_1_date}):
    - Also capture falconctl --backend and --rfm-history output where supported.

Changes introduced with ${version_3_10_2} (${version_3_10_2_date}):
    - Capture telemetry counters.

Changes introduced with ${version_3_10_3} (${version_3_10_3_date}):
    - Compress with gzip if xz is unavailable

Changes introduced with ${version_3_11_0} (${version_3_11_0_date}):
    - Use /bin/sh

Changes introduced with ${version_3_11_1} (${version_3_11_1_date}):
    - Collect cgroup memory files.

Changes introduced with ${version_3_11_2} (${version_3_11_2_date}):
    - Capture telemetry counters for DaemonSet deployments
EOD
}

usage() {
    echo "Usage: $progname [-h|--help]"
    echo "        [-s|--show-change-log]"
    echo "        [-u|--unobtrusive]"
    echo "        [-d|--daemonset]"
    echo "        [--enable-sysrq]"
    echo
    echo "${progname} ${version_current} ${version_current_date}"
}

while [ "$#" -gt 0 ]; do
    case "$1" in
      -h|--help)
          usage
          shift
          exit 0
          ;;

      -s|--show-change-log)
          display_changes
          shift
          exit 0
          ;;

      -u|--unobtrusive)
          unobtrusive=1
          echo "$progname: diagnostic collection will minimize impact on system performance"
          shift
          ;;

      --enable-sysrq)
          enable_sysrq=1
          echo "$progname: diagnostic sysrq will be used to collect task state and blocked tasks"
          shift
          ;;

      -d|--daemonset)
          daemonset=1
          echo "$progname: diagnostic collection will be for DaemonSet deployment"
          shift
          ;;

      -*|--*=)
          echo "$progname: unsupported flag $1" >&2
          usage
          exit 1
          ;;
    esac
done

get_path() {
    path=$1

    # For DaemonSet deployments, falcon diagnostic script is invoked within a
    # container(non-init mount namespace) with pid namespace shared with host.
    # Log files created by falcon sensor are available only in init mount namespace.
    # To collect these logs by diagnostic script, we prefix /proc/1/root to access
    # filesystem in init mount namespace.
    if [ ! -z "$daemonset" ]; then
        echo "/proc/1/root${path}"
    else
        echo "${path}"
    fi
}

VAR='/var'
ETC='/etc'
if [ ! -z "$daemonset" ]; then
    VAR='/var_host'
    ETC='/proc/1/root/etc'

    for entry in ${VAR};
    do
        if [ ! -d "$entry" ]; then
            echo "Directory $entry does not exist" >&2
            echo "Check if $entry is mounted within the Pod" >&2
            exit 1
        fi
    done
fi

#
# This script creates a working directory under /var/tmp. We place this on
# /the /var/partition so that we may hardlink to logs under /var/logs.
# Before running, it checks to see if the directory already exists, and
# deletes it, to get rid of any data from previous runs to prevent confusion.
#

#
# The diagnostic information will be collected under $diagnostic_dir
# (/var/tmp/crowdstrike_diagnostics-<hostname>).
#
# The contents of $diagnostic_dir will be tar/zipped into
# /var/tmp/crowdstrike_diagnostics-<hostname>-<date>.tar.xz
#
var_tmp="$VAR/tmp"
diagnostic_subdir="crowdstrike_diagnostics-$(hostname)-$(date +%F-%H-%M)"
diagnostic_dir=${var_tmp}/${diagnostic_subdir}
compression_opt=""
compression_suffix=""
if [ -x "$(command -v xz)" ]; then
    compression_opt="J"
    compression_suffix=".xz"
elif [ -x "$(command -v gzip)" ]; then
    compression_opt="z"
    compression_suffix=".gz"
fi

diagnostic_file=${diagnostic_subdir}.tar${compression_suffix}
extended_subdir="extended"
extended_dir="$diagnostic_dir/$extended_subdir"

if [ -d "$diagnostic_dir" ]; then
    rm -rf "$diagnostic_dir"
fi

mkdir -p "$diagnostic_dir"
mkdir -p "$extended_dir"

log_file="$diagnostic_dir/falcon_diagnostic.txt"
host_file="$diagnostic_dir/hardware_statistics.txt"
dmesg_file="$diagnostic_dir/dmesg_logfile.txt"
kernelmodule_file="$diagnostic_dir/kernelmodule_logfile.txt"
syslog_file="$diagnostic_dir/syslog_file.txt"
error_file="$diagnostic_dir/.error_log.txt"
readme_file="$diagnostic_dir/README"

#
# Make sure we can create the log file
#
if ! cat /dev/null > "$log_file" ; then
    echo "Could not write to log file $log_file" 1>&2
    exit 1
fi

finish() {
    #
    # xz up the artifacts
    #
    echo "Creating archive of the results in ${var_tmp}/${diagnostic_file}"
    echo "Use 'tar x${compression_opt}f ${var_tmp}/${diagnostic_file}' to extract"
    cd "$var_tmp"
    tar "-ch${compression_opt}f" "$diagnostic_file" "$diagnostic_subdir"
    rm -rf "$diagnostic_subdir"

    return 0
}

trap finish EXIT

#
# Root check
#
printf "Root Check\n" >> "$log_file"
if [ "$(id -u)" -ne 0 ] ; then
    echo "Must be root to run this script! Exiting diagnostics." | tee -a "$log_file"
    echo "id -u: $(id -u); id -g: $(id -g)" | tee -a "$log_file"
    exit 1
fi
printf "Root Check completed\n" >> "$log_file"

#
# Request telemetry counters.
#
if [ -n "$(/opt/CrowdStrike/falconctl 2>&1 | grep loginterval=)" ]; then
    telemetry_options="--loginterval=5 --logduration=5"
else
    # Versions of the sensor prior to 7.02 don't have the --loginterval and
    # --logduration options.
    telemetry_options=""
fi
telemetry_request_time="$(date +%s)"
printf "Requesting telemetry counters\n" >> "$log_file"

# $telemetry_options may expand to multiple words.
# shellcheck disable=SC2086
/opt/CrowdStrike/falconctl -s --logcounters=true $telemetry_options >> "$log_file"

#
# Distribution checks
#
RHEL=0
UBUNTU=0
SUSE=0
AMZN=0

if [ -e "$ETC/redhat-release" ]; then
    RHEL=1
    printf "RHEL system found\n" >> "$log_file"
    cat "$ETC/redhat-release" >> "$log_file"
elif [ -e "$ETC/debian_version" ]; then
    UBUNTU=1
    printf "Ubuntu system found\n" >> "$log_file"
    cat "$ETC/debian_version" >> "$log_file"
elif [ -e "$ETC/SuSE-release" ]; then
    SUSE=1
    printf "SUSE system found\n" >> "$log_file"
    cat "$ETC/SuSE-release" >> "$log_file"
elif [ -e "$ETC/system-release" ]; then
    AMZN=1
    printf "Amazon system found\n" >> "$log_file"
    cat "$ETC/system-release" >> "$log_file"
else
    printf "Unknown distribution\n" >> "$log_file"
    if [ -e "$ETC/os-release" ]; then
        cat "$ETC/os-release" >> "$log_file"
    fi
fi

#
# Collect syslog
#
printf "Collecting syslog\n" | tee -a "$log_file"
if [ -f "$VAR/log/syslog" ]; then
    echo "`grep falcon $VAR/log/syslog | tail -n 10000`" >> "$syslog_file"
    echo "Syslog Data Found" | tee -a "$log_file"
    echo | tee -a "$log_file"
elif [ -f "$VAR/log/messages" ]; then
    echo "`grep falcon $VAR/log/messages | tail -n 10000`" >> "$syslog_file"
    echo "Syslog Data Found" | tee -a "$log_file"
    echo | tee -a "$log_file"
else
    echo "Syslog Data was NOT found!" | tee -a "$log_file"
    echo | tee -a "$log_file"
fi

#
# Collect dmesg
#
printf "Collecting dmesg\n" | tee -a "$log_file"
echo "`dmesg`" >> "$dmesg_file"
printf "Gathered dmesg\n"
echo | tee -a "$log_file"

#
# Check CID
#
echo "----------------CID and AID----------------" >> "$log_file"
printf "Checking if Customer ID (aka CID) has been set\n" | tee -a "$log_file"
cid="$(/opt/CrowdStrike/falconctl -g --cid | grep -o '[a-zA-Z0-9]*' | tail -n 1)"
if [ -z "$cid" ]; then
    echo "Customer ID has NOT been set" | tee -a "$log_file"
    echo | tee -a "$log_file"
else
    echo "Customer ID is $cid" | tee -a "$log_file"
    echo | tee -a "$log_file"
fi

#
# Check AID
#
printf "Checking if the sensor's agent ID (aka AID) has been generated\n" | tee -a "$log_file"
aid="$(/opt/CrowdStrike/falconctl -g --aid | grep -o '[a-zA-Z0-9]*' | tail -n 1)"
if [ -z "$aid" ] || [ "$aid" = "set" ]; then
    echo "Agent ID has NOT been generated" | tee -a "$log_file"
    echo | tee -a "$log_file"
else
    echo "Agent ID is $aid" | tee -a "$log_file"
    echo | tee -a "$log_file"
fi

#
# Check Backend
#
echo "----------------Backend----------------------" >> "$log_file"
printf "Checking if the sensor's backend has been set\n" | tee -a "$log_file"
backend="$(/opt/CrowdStrike/falconctl -g --backend | grep -o '[a-z]*' | tail -n 1)"
if [ -z "$backend" ] || [ "$backend" = "set" ]; then
    echo "Backend has NOT been set" | tee -a "$log_file"
    echo | tee -a "$log_file"
else
    echo "Backend is $backend" | tee -a "$log_file"
    echo | tee -a "$log_file"
fi

#
# Check if sensor is running
#
echo "----------------Sensor Status----------------" >> "$log_file"
printf "Checking if falcon-sensor is currently running\n" | tee -a "$log_file"
running="$(ps -e | grep -e falcon-sensor)"
if [ ! -z "$running" ]; then
    echo "falcon-sensor is running" | tee -a "$log_file"
    echo "$running" >> "$log_file"
    echo | tee -a "$log_file"
else
    echo "ERROR falon-sensor is NOT running!" | tee -a "$log_file" "$error_file"
    echo | tee -a "$log_file"
fi

#
# If sensor isn't running, collect the service status
# keeping in mind of systemd vs init requirements
#
# NOTE: This is not applicable for DaemonSet
#
if [ -z "$running" ] && [ "$daemonset" ]; then
    sysv_init=0
    systemd=0
    if [ -x "$(command -v systemctl)" ]; then
        systemd=1
    else
        sysv_init=1
    fi

    if [ "$systemd" = 1 ]; then
        systemctl show falcon-sensor >> "$log_file"
    elif [ "$sysv_init" = 1 ]; then
        if [ -f /etc/init.d/falcon-sensor ]; then
            cat /etc/init.d/falcon-sensor >> "$log_file"
        else
            echo "Unknown location for init script" >> "$log_file"
        fi
    fi
fi

if [ -z "$unobtrusive" ]; then
    #
    # Check the installed sensor version
    #
    echo "------------Installed Sensor Version------------" >> "$log_file"
    echo "`/opt/CrowdStrike/falconctl -g --version`" | tee -a "$log_file"
    printf "Gathered version of the current running sensor\n"
    echo | tee -a "$log_file"

    #
    # Check the installed RPM package info from the RPM/DPKG database
    #
    echo "----------------RPM----------------" >> "$log_file"
    printf "Gathering information for the last RPM Package installed\n" | tee -a "$log_file"
    printf "If using Cloud Updates, this will NOT NECESSARILY be the sensor version running.\n" | tee -a "$log_file"
    if [ "$UBUNTU" = 1 ]; then
        echo "`dpkg -s falcon-sensor`" >> "$log_file"
    else
        echo "`rpm -qi falcon-sensor`" >> "$log_file"
    fi
    printf "Gathered installed RPM Package Info\n"
    echo | tee -a "$log_file"

    echo "$(readlink -f /proc/"$(pgrep falcon-sensor)"/exe)" | tee -a "$log_file"

    #
    # Check falcon-sensor status
    #
    printf "Gathering falcon-sensor status\n"
    echo "`service falcon-sensor status 2>&1`" >> "$log_file"
    printf "Gathered falcon-sensor status\n"
    echo | tee -a "$log_file"

    #
    # Verify sensor files on disk
    #
    echo "----------------Sensor Files----------------" >> "$log_file"
    printf "Checking if sensor files are on disk\n" | tee -a "$log_file"
    if [ -d "/opt/CrowdStrike" ]; then
        if [ -x "$(command -v ls)" ]; then
            #
            # For DaemonSet, dump the contents from host mount namespace
            #
            if [ ! -z "$daemonset" -a -d "/proc/1/root/opt/CrowdStrike" ]; then
                ls -al /proc/1/root/opt/CrowdStrike >> "$log_file"
            fi
            ls -al /opt/CrowdStrike /opt/CrowdStrike/falcon-sensor >> "$log_file"
            echo "Sensor files were found" | tee -a "$log_file"
            echo | tee -a "$log_file"
        fi
    else
        echo "Sensor files were NOT found on disk!" | tee -a "$log_file" "$error_file"
        echo | tee -a "$log_file"
    fi

    #
    # Check kernel modules to verify the Falcon sensor's kernel modules are running
    #
    echo "----------------Kernel Module Status----------------" >> "$log_file"
    printf "Checking if kernel modules are running\n" | tee -a "$log_file"
    if [ -x "$(command -v lsmod)" ]; then
        lsmodules="$(lsmod | grep falcon)"
        if [ "$lsmodules" ]; then
            echo "$lsmodules" | tee -a "$log_file"
            echo "Kernel modules are running" | tee -a "$log_file"
            echo | tee -a "$log_file"
        else
            echo "Kernel modules are NOT running" | tee -a "$log_file" "$error_file"
            echo | tee -a "$log_file"
        fi
    fi

    #
    # Checking if running kernel is supported
    #
    echo "----------------Kernel Version Supported----------------" >> "$log_file"
    printf "Checking if currently running kernel is supported\n" | tee -a "$log_file"
    supported=0
    if [ -x "$(command -v uname)" ]; then
        curr_kernel="$(uname -r)"
    else
        curr_kernel="unknown"
        echo "Unable to determine currently running kernel!" | tee -a "$log_file" "$error_file"
    fi

    echo "Currently running kernel is $curr_kernel" | tee -a "$log_file"

    if [ -f "/opt/CrowdStrike/KernelModuleArchive" ]; then
        if [ -x "$(command -v strings)" ] && [ -x "$(command -v xz)" ]; then
            supported_kernels="$(xz -dc /opt/CrowdStrike/KernelModuleArchive | strings | grep '^[2-5]\..*')"
            echo "$supported_kernels" >> "$kernelmodule_file"
            for kernel in $supported_kernels; do
                if [ "$curr_kernel" = "$kernel" ]; then
                    supported=1
                    break
                fi
            done
        fi
    fi
    if [ "$supported" = 1 ]; then
        echo "Sensor kernel support: $curr_kernel is natively supported" | tee -a "$log_file"
        echo | tee -a "$log_file"
    else
        KMAEXT="/opt/CrowdStrike/KernelModuleArchiveExt"
        if [ ! -z "$daemonset" ]; then
            #
            # For DaemonSet, downloaded content from cloud are present only in host mount namespace
            #
            KMAEXT="/proc/1/root$KMAEXT"
        fi

        if [ -f "$KMAEXT" ]; then
            echo "Sensor kernel support: $curr_kernel is NOT natively supported, but MAY be supported via a ZTL update" | tee -a "$log_file" "$error_file"
        else
            echo "Sensor kernel support: $curr_kernel is NOT supported" | tee -a "$log_file" "$error_file"
        fi
    fi
    echo | tee -a "$log_file"

    #
    # sha256 all files in CrowdStrike dir
    #
    echo "----------------SHA 256 Hashes----------------" >> "$log_file"
    echo "Gathering SHA256 hashes"
    if [ -x "$(command -v sha256sum)" -a -d "/opt/CrowdStrike" ]; then
        for file in `ls /opt/CrowdStrike`; do
            echo "`sha256sum /opt/CrowdStrike/$file 2>&1`" >> "$log_file"
        done

        #
        # For DaemonSet, downloaded content from cloud are present only in host mount namespace
        #
        if [ ! -z "$daemonset" -a -d "/proc/1/root/opt/CrowdStrike" ]; then
            for file in `ls /proc/1/root/opt/CrowdStrike`; do
                echo "`sha256sum /proc/1/root/opt/CrowdStrike/$file 2>&1`" >> "$log_file"
            done
        fi
    fi
    echo | tee -a "$log_file"

    #
    # Check status of SELinux (RHEL/CentOS/SLES)
    #
    echo "----------------SELinux Status----------------" >> "$log_file"
    echo "Gathering SELinux Status"
    if [ ! -x "$(command -v sestatus)" ]; then
        echo "sestatus not installed." >> "$log_file"
    else
        echo "`sestatus`" >> "$log_file"
        echo | tee -a "$log_file"
    fi

    #
    # Check status of App Armor (Ubuntu)
    #
    echo "----------------App Armor Status----------------" >> "$log_file"
    echo "Gathering App Armor Status"
    if [ ! -x "$(command -v aa-status)" ]; then
        echo "aa-status not installed." >> "$log_file"
    else
        echo "`aa-status`" >> "$log_file"
        echo | tee -a "$log_file"
    fi

    printf "Running Network Checks\n"

    #
    # Verify sensor is connected to the cloud
    #
    echo "----------------Connectivity Info----------------" >> "$log_file"
    printf "Checking if sensor is connected to CrowdStrike Cloud\n" | tee -a "$log_file"
    if [ -x "$(command -v netstat)" ]; then
        cloud_check="$(netstat -tapn | grep falcon-sensor)"
        if [ -z "$cloud_check" ]; then
            echo "falcon-sensor is Not connected to CrowdStrike Cloud" | tee -a "$log_file" "$error_file"
            echo | tee -a "$log_file"
        fi
    else
      echo "netstat command does not exist" | tee -a "$log_file"
    fi

    #
    # Verify sensor proxy status
    #
    echo "----------------Proxy Status----------------" >> "$log_file"
    printf "Checking proxy status\n" | tee -a "$log_file"
    proxy_check="$(/opt/CrowdStrike/falconctl -g --apd | grep -o -P '([a-zA-Z0-9]*)' | tail -n 1)"
    proxy="$(/opt/CrowdStrike/falconctl -g --apd --aph --app)"
    if [ -z "$proxy_check" ] || [ "$proxy_check" = "set" ]; then
        echo "Proxy settings are NOT set" | tee -a "$log_file"
        echo | tee -a "$log_file"
    else
        echo "$proxy" | tee -a "$log_file"
        echo | tee -a "$log_file"
    fi

    #
    # Check Installed OpenSSL versions and attempt connection
    #
    if [ ! -x "$(command -v openssl)" ]; then
        echo "OpenSSL NOT installed. It is required for connectivity." >> "$log_file" "$error_file"
        else
        echo "----------------Installed SSL Versions----------------" >> "$log_file"
        printf "Gathering OpenSSL version information\n"
        echo "`rpm -qa |grep -i openssl`" >> "$log_file"
        echo | tee -a "$log_file"
        printf "Attempting OpenSSL connection to ts01-b.cloudsink.net:443\n" >> "$log_file"
        echo "Please Note: This check will fail if a proxy is enabled." >> "$log_file"
        echo "`openssl s_client -connect ts01-b.cloudsink.net:443`" 2>&1 >> "$log_file"
        echo | tee -a "$log_file"
    fi

    #
    # Check IP tables for any custom routing rules that may interfere
    #
    echo "----------------IP Tables----------------" >> "$log_file"
    printf "Gathering IP Tables rules\n"
    echo "`iptables -L -n`" >> "$log_file"
    echo | tee -a "$log_file"

    printf "Checking System Hardware\n"

    #
    # Check disk space
    #
    echo "----------------Disk Space Information----------------" >> "$host_file"
    printf "Gathering disk space information\n"
    echo "`df -h`" >> "$host_file"
    echo | tee -a "$host_file"

    #
    # Check CPU and IO info
    #
    if [ ! -x "$(command -v iostat)" ]; then
        echo "iostat not installed." >> "$host_file"
        else
        echo "----------------CPU and I/O Info----------------" >> "$host_file"
        printf "Gathering CPU and I/O information\n"
        echo "`iostat`" >> "$host_file"
        echo | tee -a "$host_file"
    fi

    #
    # Check Memory Information
    #
    if [ ! -x "$(command -v vmstat)" ]; then
        echo "vmstat not installed." >> "$host_file"
        else
        echo "----------------Memory Info----------------" >> "$host_file"
        printf "Gathering Memory information\n"
        echo "`vmstat`" >> "$host_file"
        echo | tee -a "$host_file"
    fi

    #
    # Check Process Information
    #
    echo "----------------Processor Info----------------" >> "$host_file"
    printf "Collecting processor information\n" | tee -a "$host_file"
    if [ -x "$(command -v lscpu)" ]; then
        echo "`lscpu`" >> "$host_file"
        echo | tee -a "$host_file"
    fi

    #
    #Check to see how much memory the sensor is using per CPU Thread
    #
    echo "--------------Per-Thread Memory Usage--------------" >> "$log_file"
    if [ -x "$(command -v pgrep)" ]; then
        if [ "$running" ]; then
            pid="$(pgrep falcon-sensor)"
            if [ "$pid" ]; then
                psid="$(ps -p "$pid" -L -o pid,tid,psr,pcpu,comm=)"
                echo "$psid" >> "$log_file"
                echo | tee -a "$log_file"
                echo "Collected per-thread usage" | tee -a "$log_file"
                echo | tee -a "$log_file"
            fi
        else
            echo "Per-thread usage cannot be collected because falon-sensor is not running!" | tee -a "$log_file"
            echo | tee -a "$log_file"
        fi
    else
        echo "pgrep command does not exist!" | tee -a "$log_file"
        echo | tee -a "$log_file"
    fi
fi

#
# Check queue depths
#
echo "----------------Queue Info----------------" >> "$log_file"
printf "Gathering queue depths\n"
printf "Current Max Total-enqueued\n"
for f in /proc/falcon_lsm_serviceable/queue_depth/*; do
    echo "$(basename "$f")" >> "$log_file"
    cat "$f" >> "$log_file"
done
echo | tee -a "$log_file"

if [ -z "$unobtrusive" ]; then
     #
     # Check diskspace
     #
     echo "----------------Disk Space Information----------------" >> "$host_file"
     printf "Gathering disk space information\n"
     echo "`df -h`" >> "$host_file"
     echo | tee -a "$host_file"

     #
     # Check CPU and IO info
     #
     if [ ! -x "$(command -v iostat)" ]; then
         echo "iostat not installed." >> "$host_file"
         else
         echo "----------------CPU and I/O Info----------------" >> "$host_file"
         printf "Gathering CPU and I/O information\n"
         echo "`iostat`" >> "$host_file"
         echo | tee -a "$host_file"
     fi

     #
     # Check Memory Information
     #
     if [ ! -x "$(command -v vmstat)" ]; then
         echo "vmstat not installed." >> "$host_file"
         else
         echo "----------------Memory Info----------------" >> "$host_file"
         printf "Gathering Memory information\n"
         echo "`vmstat`" >> "$host_file"
         echo | tee -a "$host_file"
     fi
fi

printf "Gathering Top information\n" | tee -a "$host_file"
echo "`top -b -n 1`" >> "$host_file"
echo | tee -a "$host_file"

if [ -z "$unobtrusive" ]; then
    #
    # Check fork rate
    #
    if [ ! -x "$(command -v vmstat)" ]; then
        echo "vmstat not installed." >> "$host_file"
        else
        echo "----------------Fork Rate----------------" >> "$host_file"
        printf "Gathering system fork rate\n"
        t=5
        start="$(vmstat -f | awk '{print $1}')"
        sleep "$t"
        end="$(vmstat -f | awk '{print $1}')"
        rate="$(expr "(" "$end" - "$start" ")" / "$t")"
        echo "$rate forks per second" >> "$host_file"
        echo | tee -a "$host_file"
    fi

     #
     # If error_log exists, tail it's contents to terminal
     #
     if [ -e "$diagnostic_dir/error_log.txt" ]; then
         echo "------------------------------------------"
         echo "`tail -n 100 $diagnostic_dir/error_log.txt`"
         echo "------------------------------------------"
     fi
fi

printf "Gathering extended configuration and state information\n" | tee -a "$log_file"

pids="$(ps augx | grep -e kcs- -e falcon-sensor -e /opt/CrowdStrike/falcond | grep -v grep | awk '{ print $2 }')"

for i in 1 2 3 4 5 6 7 8 9 10
do
    for pid in `echo $pids`; do
        name="$(cat "/proc/$pid/comm")"
        echo "$name"                  >> "$extended_dir/kstacks_$i.txt"
        echo 'Call Stack:'            >> "$extended_dir/kstacks_$i.txt"
        cat "/proc/$pid/stack"        >> "$extended_dir/kstacks_$i.txt"
        echo                          >> "$extended_dir/kstacks_$i.txt"
    done
done

#
# Below, we create a 2 dimensional array, containing commands to execute
# (to gather diagnostic information) and the target filenames to write
# the output of the command.
#
# Some commands may either copy or link an existing file, in which
# case the target filename should be /dev/null.
#
# On some customer systems, these commands may fail. Either because the
# OS doesn't support the command or the required package may not be
# installed. In this case, the command will quietly fail and the target
# file will not be generated.
#
cd "$extended_dir"

printf "${progname} ${version_current} ${version_current_date}

The following files are created.

    falcon_diagnostic.txt:    a variety of server configuration and state information.
    hardware_statistics.txt:  server CPU, memory, process and disk information.
    dmesg_logfile.txt:        contents of /var/log/dmesg, the kernel ring buffer.
    kernelmodule_logfile.txt: the kernel configuration log file.
    syslog_file.txt:          the last 10000 lines of /var/log/messages or /var/log/syslog.
    error_log.txt:            the Falcon sensor error log file.

In addition, the folowing diagnostic and log files are created.

" >> "$readme_file"

var_log_mount_point="$(df "$VAR/log/." | tail -1 | awk '{ print $6 }')"
var_tmp_mount_point="$(df "$VAR/tmp/." | tail -1 | awk '{ print $6 }')"

if [ "$var_log_mount_point" = "$var_tmp_mount_point" ]; then
    same=1
else
    same=0
fi

if [ -z "$unobtrusive" ]; then
    if [ "$same" -eq 1 ]; then find "$VAR/log" -name "dmesg*" -exec ln -s  {} . \;; else find "$VAR/log" -name "dmesg*" -exec cp {} . \;; fi
    if [ "$same" -eq 1 ]; then find "$VAR/log" -name "falcon-sensor*" -exec ln -s  {} . \;; else find "$VAR/log" -name "falcon-sensor*" -exec cp {} . \;; fi
    if [ "$same" -eq 1 ]; then find "$VAR/log" -name "messages*" -exec ln -s  {} . \;; else find "$VAR/log" -name "messages*" -exec cp {} . \;; fi
    if [ "$same" -eq 1 ]; then find "$VAR/log" -name "syslog*" -exec ln -s  {} . \;; else find "$VAR/log" -name "syslog*" -exec cp {} . \;; fi
    if [ "$same" -eq 1 ]; then ln "$VAR/log/boot.log"; else cp "$VAR/log/boot.log" .; fi
    if [ "$same" -eq 1 ]; then ln "$VAR/log/falconctl.log"; else cp "$VAR/log/falconctl.log" .; fi
    if [ "$same" -eq 1 ]; then ln "$VAR/log/falcon-libbpf.log"; else cp "$VAR/log/falcon-libbpf.log" .; fi
fi > "$error_file" 2>&1

echo queue current max | awk '{ printf "%-9s %-8s %-8s\n", $1, $2, $3 }' >> queue_depth.txt
for f in /proc/falcon_lsm_serviceable/queue_depth/*; do
    queue="$(basename "$f")"
    rates="$(cat "$f")"
    echo "$queue" "$rates" | awk '{ printf "%-9s %-8s %-8s", $1, $2, $3 }'   >> queue_depth.txt
    echo                                                                 >> queue_depth.txt
done

#
# Identify sensor process name
#
sensor_ps_name="falcon-sensor"
if [ -z "$(pidof -s "$sensor_ps_name")" ]; then
    sensor_ps_name="falcon-sensor-bpf"
fi
sensor_pid="$(pidof -s "$sensor_ps_name")"
uname_r="$(uname -r || echo 'unknown-kernel')"

command_array_length=0

# Store a commmand to be executed later.  Usage:
#   add_command CMD STDOUT_FILENAME
# CMD must be runnable through `eval`, so should be wrapped in single quotes.
add_command() {
    eval "command_array_command_${command_array_length}='$(echo "$1" | sed "s/'/'\\\\''/g")'"
    eval "command_array_output_${command_array_length}='$(echo "$2" | sed "s/'/'\\\\''/g")'"
    command_array_length="$(expr "$command_array_length" + 1)"
}

# SC2016: no expansion in single quotes.  The following line disables
# that warning for the duration of the `if`.
# shellcheck disable=SC2016
if [ -z "$unobtrusive" ]; then
    add_command 'cat /proc/${sensor_pid}/maps'                                                                fs-proc-maps.txt
    add_command 'cat /proc/${sensor_pid}/numa_maps'                                                           fs-proc-numamaps.txt
    add_command 'cat /proc/${sensor_pid}/smaps'                                                               fs-proc-smaps.txt
    add_command 'cat /proc/${sensor_pid}/smaps_rollup'                                                        fs-proc-smaps_rollup.txt
    add_command 'cat /proc/${sensor_pid}/stack'                                                               fs-proc-stack.txt
    add_command 'cat /proc/${sensor_pid}/status'                                                              fs-proc-status.txt
    add_command 'cat /proc/buddyinfo'                                                                         fs-proc-buddyinfo.txt
    add_command 'cat /proc/cmdline'                                                                           proc-cmdline.txt
    add_command 'cat /proc/meminfo'                                                                           proc-meminfo.txt
    add_command 'cat /proc/pagetypeinfo'                                                                      proc-pagetypeinfo.txt
    add_command 'cat /proc/slabinfo'                                                                          proc-slabinfo.txt
    add_command 'cat /proc/swaps'                                                                             proc-swaps.txt
    add_command 'cat /proc/sys/kernel/tainted'                                                                proc-kernel-tainted.txt
    add_command 'cat /proc/vmallocinfo'                                                                       proc-vmallocinfo.txt
    add_command 'cat /proc/vmstat'                                                                            proc-vmstat.txt
    add_command 'cat /proc/zoneinfo'                                                                          proc-zoneinfo.txt
    add_command 'cat /proc/cpuinfo'                                                                           proc-cpuinfo.txt
    add_command 'grep -i CrowdStrike /proc/keys'                                                              proc-keys-CrowdStrike.txt
    add_command 'dmidecode -t bios'                                                                           bios.txt
    add_command 'dpkg-query -l'                                                                               dpkg-query.txt
    add_command 'echo ${version_current} ${version_current_date}'                                             falcon_diagnostic-version.txt
    add_command 'fdisk -l'                                                                                    fdisk-l.txt
    add_command 'fips-mode-setup --check'                                                                     fips-mode-setup.txt
    add_command 'find /proc/sys/kernel /proc/sys/vm -type f -print -exec cat {} \;'                           proc-sys.txt
    add_command 'findmnt -a'                                                                                  find-mnt.txt
    add_command 'free -h'                                                                                     free.txt
    add_command 'hostinfo'                                                                                    hostinfo.txt
    add_command 'ifconfig'                                                                                    ifconfig.txt
    add_command 'ip link show'                                                                                ip-link-show.txt
    add_command 'lsblk'                                                                                       lsblk.txt
    add_command 'lscpu'                                                                                       lscpu.txt
    add_command 'lsdev'                                                                                       lsdev.txt
    add_command 'lshw'                                                                                        lshw.txt
    add_command 'lsipc'                                                                                       lsipc.txt
    add_command 'lsinitrd'                                                                                    lsinitrd.txt
    add_command 'lslocks'                                                                                     lslocks.txt
    add_command 'lsmem'                                                                                       lsmem.txt
    add_command 'lsmod'                                                                                       lsmod.txt
    add_command 'lsof'                                                                                        lsof.txt
    add_command 'lsof -p ${sensor_pid}'                                                                       fs-lsof.txt
    add_command 'lspci'                                                                                       lspci.txt
    add_command 'lsscsi'                                                                                      lsscsi.txt
    add_command 'ls -l /opt/CrowdStrike'                                                                      ls-opt-crowdstrike.txt
    add_command 'ls -lRh ${VAR}/crash/'                                                                       ls-var-crash.txt
    add_command 'ls -l /lib/modules/${uname_r}/extra'                                                         ls-lib-modules-kernel-extra.txt
    add_command 'mokutil --sb-state'                                                                          mokutil--sb-state.txt
    add_command 'mount -l'                                                                                    mount.txt
    add_command 'netstat -i'                                                                                  netstat-i.txt
    add_command 'netstat -r'                                                                                  netstat-r.txt
    add_command 'netstat -s'                                                                                  netstat-s.txt
    add_command 'nstat'                                                                                       nstat.txt
    add_command 'pmap -x ${sensor_pid}'                                                                       fs-pmap-x.txt
    add_command 'pmap -X ${sensor_pid}'                                                                       fs-pmap-X.txt
    add_command 'prtstat ${sensor_pid}'                                                                       fs-prtstat.txt
    add_command 'ps agxfww -eo user,pid,ppid,%cpu,cputime,%mem,cls,lwp,nlwp,pri,trs,vsz,rss,sz,size,cmd'      ps-agxz.txt
    add_command 'pstack ${sensor_pid}'                                                                        fs-pstack.txt
    add_command 'rpm -qa'                                                                                     rpm-qa.txt
    add_command 'service --status-all'                                                                        service-status-all.txt
    add_command 'slabtop -o'                                                                                  slabtop.txt
    add_command 'sysctl -A'                                                                                   sysctl-A.txt
    add_command 'systemctl -al'                                                                               systemctl-aL.txt
    add_command 'systemctl -ln 2000 status falcon-sensor'                                                     systemctl-ln-falcon-sensor.txt
    add_command 'systemctl status kdump.service'                                                              systemctl-kdump.service.txt
    add_command 'systemd-detect-virt'                                                                         systemd-detect-virt.txt
    add_command 'systemd-cgtop -b -n 1'                                                                       systemd-cgtop.txt
    add_command 'top -bH -n1'                                                                                 top.txt
    add_command 'pstree -apsn'                                                                                pstree.txt
    add_command 'ulimit -a'                                                                                   ulimit-a.txt
    add_command 'uname -a'                                                                                    uname-a.txt
    add_command 'uptime'                                                                                      uptime.txt
    add_command 'vmstat -m'                                                                                   vmstat-m.txt
    add_command 'vmstat -s'                                                                                   vmstat-s.txt
    add_command 'vmstat -w'                                                                                   vmstat-w.txt
    add_command 'echo --cid:                && /opt/CrowdStrike/falconctl -g --cid && echo'                   falconctl.txt
    add_command 'echo --aid:                && /opt/CrowdStrike/falconctl -g --aid && echo'                   falconctl.txt
    add_command 'echo --apd:                && /opt/CrowdStrike/falconctl -g --apd && echo'                   falconctl.txt
    add_command 'echo --aph:                && /opt/CrowdStrike/falconctl -g --aph && echo'                   falconctl.txt
    add_command 'echo --app:                && /opt/CrowdStrike/falconctl -g --app && echo'                   falconctl.txt
    add_command 'echo --rfm-state:          && /opt/CrowdStrike/falconctl -g --rfm-state && echo'             falconctl.txt
    add_command 'echo --rfm-reason:         && /opt/CrowdStrike/falconctl -g --rfm-reason && echo'            falconctl.txt
    add_command 'echo --trace:              && /opt/CrowdStrike/falconctl -g --trace && echo'                 falconctl.txt
    add_command 'echo --feature:            && /opt/CrowdStrike/falconctl -g --feature && echo'               falconctl.txt
    add_command 'echo --metadata-query:     && /opt/CrowdStrike/falconctl -g --metadata-query && echo'        falconctl.txt
    add_command 'echo --version:            && /opt/CrowdStrike/falconctl -g --version && echo'               falconctl.txt
    add_command 'echo --billing:            && /opt/CrowdStrike/falconctl -g --billing && echo'               falconctl.txt
    add_command 'echo --tags:               && /opt/CrowdStrike/falconctl -g --tags && echo'                  falconctl.txt
    add_command 'echo --provisioning-token: && /opt/CrowdStrike/falconctl -g --provisioning-token && echo'    falconctl.txt
    add_command 'echo --systags:            && /opt/CrowdStrike/falconctl -g --systags && echo'               falconctl.txt
    add_command 'find /proc/falcon_lsm_serviceable -type f -print -exec cat {} \;'                            falcon_lsm_serviceable.txt
    add_command 'cat /proc/falcon_lsm_serviceable/poolcounts | sort -n -k 2 -r'                               falcon_lsm_serviceable_poolcounts.txt
    add_command 'cat /proc/falcon_lsm_serviceable/poolbytes | sort -n -k 2 -r'                                falcon_lsm_serviceable_poolbytes.txt
    add_command 'find /proc/falcon_lsm_serviceable -type f -print -exec cat {} \;'                            falcon_lsm_serviceable.txt
    add_command 'cp ${ETC}/fstab .'                                                                           /dev/null
    add_command 'cp ${ETC}/os-release .'                                                                      /dev/null
    add_command 'cp ${ETC}/redhat-release .'                                                                  /dev/null
    add_command 'cp ${ETC}/SuSE-release .'                                                                    /dev/null
    add_command 'cp ${ETC}/debian_version .'                                                                  /dev/null
    add_command 'cp ${ETC}/security/limits.conf .'                                                            /dev/null
    add_command 'cp ${ETC}/sysctl.conf .'                                                                     /dev/null
    add_command 'cp ${ETC}/system-release .'                                                                  /dev/null
    add_command 'cp ${ETC}/systemd/system/falcon-sensor.service.d/override.conf .'                            /dev/null
    add_command 'cp /opt/CrowdStrike/Registry.bin .'                                                          /dev/null
    add_command 'cp /usr/lib/systemd/system/falcon-sensor.service .'                                          /dev/null

    add_command '[ "$enable_sysrq" -eq 1 ] && echo t > /proc/sysrq-trigger'                                 /dev/null
    add_command '[ "$enable_sysrq" -eq 1 ] && echo w > /proc/sysrq-trigger'                                 /dev/null

    add_command 'supportconfig -Rl ${diagnostic_dir}'                                                         /dev/null

    if [ ! -z "$daemonset" ]; then
        add_command 'ls -l /proc/1/root/opt/CrowdStrike'                                                      ls-opt-crowdstrike.txt
        add_command 'ls -l /proc/1/root/lib/modules/${uname_r}/extra'                                         ls-lib-modules-kernel-extra.txt
        add_command 'cp /proc/1/root/opt/CrowdStrike/Registry.bin .'                                          /dev/null
    fi

else
    add_command 'tail -10000 ${VAR}/log/messages'                                                             messages
    add_command 'tail -10000 ${VAR}/log/dmesg'                                                                dmesg
    add_command 'tail -10000 ${VAR}/log/syslog'                                                               syslog
    add_command 'echo --cid:                && /opt/CrowdStrike/falconctl -g --cid && echo'                   falconctl.txt
    add_command 'echo ${version_current} ${version_current_date}'                                             falcon_diagnostic-version.txt
    add_command 'ls -l /opt/CrowdStrike'                                                                      ls-opt-crowdstrike.txt
    add_command 'ls -lRh ${VAR}/crash/'                                                                       ls-var-crash.txt
    add_command 'ls  -l /lib/modules/${uname_r}/extra'                                                        ls-lib-modules-kernel-extra.txt
    add_command 'mokutil --sb-state'                                                                          mokutil--sb-state.txt
    add_command 'ps agxfww -eo user,pid,ppid,%cpu,cputime,%mem,cls,lwp,nlwp,pri,trs,vsz,rss,sz,size,cmd'      ps-agxz.txt
    add_command 'grep -i CrowdStrike /proc/keys'                                                              proc-keys-CrowdStrike.txt
    add_command 'top -bH -n1'                                                                                 top.txt
    add_command 'echo --aid:                && /opt/CrowdStrike/falconctl -g --aid && echo'                   falconctl.txt
    add_command 'echo --apd:                && /opt/CrowdStrike/falconctl -g --apd && echo'                   falconctl.txt
    add_command 'echo --aph:                && /opt/CrowdStrike/falconctl -g --aph && echo'                   falconctl.txt
    add_command 'echo --app:                && /opt/CrowdStrike/falconctl -g --app && echo'                   falconctl.txt
    add_command 'echo --rfm-state:          && /opt/CrowdStrike/falconctl -g --rfm-state && echo'             falconctl.txt
    add_command 'echo --rfm-reason:         && /opt/CrowdStrike/falconctl -g --rfm-reason && echo'            falconctl.txt
    add_command 'echo --trace:              && /opt/CrowdStrike/falconctl -g --trace && echo'                 falconctl.txt
    add_command 'echo --feature:            && /opt/CrowdStrike/falconctl -g --feature && echo'               falconctl.txt
    add_command 'echo --metadata-query:     && /opt/CrowdStrike/falconctl -g --metadata-query && echo'        falconctl.txt
    add_command 'echo --version:            && /opt/CrowdStrike/falconctl -g --version && echo'               falconctl.txt
    add_command 'echo --billing:            && /opt/CrowdStrike/falconctl -g --billing && echo'               falconctl.txt
    add_command 'echo --tags:               && /opt/CrowdStrike/falconctl -g --tags && echo'                  falconctl.txt
    add_command 'echo --provisioning-token: && /opt/CrowdStrike/falconctl -g --provisioning-token && echo'    falconctl.txt
    add_command 'echo --systags:            && /opt/CrowdStrike/falconctl -g --systags && echo'               falconctl.txt
    add_command 'cat /proc/falcon_lsm_serviceable/poolcounts | sort -n -k 2 -r'                               falcon_lsm_serviceable_poolcounts.txt
    add_command 'cat /proc/falcon_lsm_serviceable/poolbytes | sort -n -k 2 -r'                                falcon_lsm_serviceable_poolbytes.txt
    add_command 'find /proc/falcon_lsm_serviceable -type f -print -exec cat {} \;'                            falcon_lsm_serviceable.txt

    if [ ! -z "$daemonset" ]; then
        add_command 'ls -l /proc/1/root/opt/CrowdStrike'                                                      ls-opt-crowdstrike.txt
        add_command 'ls -l /proc/1/root/lib/modules/${uname_r}/extra'                                         ls-lib-modules-kernel-extra.txt
    fi

fi

# falconctl commands that are not supported on all sensor versions:
# give them their own output files.
add_command 'echo --backend:            && /opt/CrowdStrike/falconctl -g --backend && echo'               falconctl-backend.txt
add_command 'echo --rfm-history:        && /opt/CrowdStrike/falconctl -g --rfm-history && echo'           falconctl-rfm-history.txt

#
# Loop through command_array, executing each command and redirecting the output
# to the specified file. If the command fails, remove the target file (unless it
# is /dev/null).
#
# In addition, generate a README listing the files generated and the command
# used to create it.
#
i=0
while [ "$i" -lt "$command_array_length" ];
do
    thiscommand="$(eval 'echo "$command_array_command_'$i'"')"
    thisoutput="$(eval 'echo "$command_array_output_'$i'"')"
    echo "$thiscommand" >> "$error_file"
    eval "$thiscommand" >> "$thisoutput" 2>> "$error_file"
    cmdretval="$?"
    echo >> "$error_file"

    if [ "$cmdretval" -eq 0 ]; then
        if [ "$thisoutput" != "/dev/null" ]; then
            echo "Created $thisoutput" | tee -a "$log_file"
            echo "    $extended_subdir/$thisoutput: output of '$thiscommand'" >> "$readme_file"
        fi
    else
        echo "'$thiscommand' not supported" | tee -a "$log_file"
        if [ "$thisoutput" != "/dev/null" ]; then
            rm -f "$thisoutput"
        fi
    fi

    i="$(expr "$i" + 1)"
done

#
# Collect telemetry logs and stop further log collection.
#
printf "Waiting for telemetry logs to exist...\n" >> "$log_file"
um_telemetry_file=$(get_path "/var/log/falcon-cstel_um.log")
km_telemetry_file=$(get_path "/var/log/falcon-cstel_km.log")
wait_time=0
done=0
while [ "$wait_time" -lt 60 ]; do
    if [ -f "$um_telemetry_file" ]; then
        if [ "$(stat -c '%Y' "$um_telemetry_file")" -ge "$telemetry_request_time" ]; then
            # Make sure the log is fully written out before we copy it.
            sleep 2
            cp -av "$um_telemetry_file" . >> "$log_file"
            done=1
        fi
    fi

    if [ -f "$km_telemetry_file" ]; then
        if [ "$(stat -c '%Y' "$km_telemetry_file")" -ge "$telemetry_request_time" ]; then
            # Make sure the log is fully written out before we copy it.
            sleep 2
            cp -av "$km_telemetry_file" . >> "$log_file"
            done=1
        fi
    fi

    if [ "$done" -ne 0 ]; then
        break
    fi

    wait_time="$(expr "$wait_time" + 1)"
    sleep 1
done
if [ -n "$telemetry_options" ]; then
    /opt/CrowdStrike/falconctl -d --logcounters --loginterval --logduration >> "$log_file" 2>&1
else
    /opt/CrowdStrike/falconctl -d --logcounters >> "$log_file" 2>&1
fi
printf "Finished capturing telemetry logs\n" >> "$log_file"

#
# Collect cgroup memory information.
#
printf "Collecting cgroup memory information...\n" >> "$log_file"
cgroup_memory_hierarchy="$(cat /proc/cgroups | grep "memory" | awk '{print $2}')"
if [ "$cgroup_memory_hierarchy" -eq 0 ]; then
    # cgroup v2
    cgroup_mount="$(cat /proc/mounts | grep "^cgroup2 " | awk '{print $2}')"
    cgroup_path="$(cat /proc/${sensor_pid}/cgroup | awk -F: '{print $3}')"
else
    # cgroup v1
    cgroup_mount="$(cat /proc/mounts | grep "^cgroup " | grep "memory" | awk '{print $2}')"
    cgroup_path="$(cat /proc/${sensor_pid}/cgroup | grep "memory" | awk -F: '{print $3}')"
fi
find "${cgroup_mount}${cgroup_path}" -maxdepth 1 -perm -u+r -name 'memory.*' -exec cp -av {} . \; >> "$log_file" 2>&1
printf "Finished collecting cgroup memory information\n" >> "$log_file"

printf "Completed Falcon diagnostic\n" | tee -a "$log_file"

exit 0
