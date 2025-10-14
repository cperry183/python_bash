#!/usr/bin/env bash
#
# Script to enable/disable consul maintenance mode
# Can enable on entire node or a specific service
#

if [ $EUID -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Check if maintenance is enabled or not
if [[ $(/usr/local/bin/consul maint | wc -l) -eq 0 ]]; then
    echo "Maintenance is not enabled on $(hostname)"
    read -p "Do you want to enable maintenance? (Y/N) : "
    if [ ${REPLY,,} = "y" ]; then
        # List all services available on the node
        #services=$(curl -s http://127.0.0.1:8500/v1/catalog/node-services/$(hostname) |jq .Services[].ID)
        services=$(/usr/local/bin/consul catalog services -node $(hostname))
        read -p "Enter a reason for maintenance and press Enter: " REASON
        [ -z "$REASON" ] && REASON="Not Given"
        PS3='Select a number and press Enter: '
        select service in "${services[@]}" node; do
            case $service in
                "node")
                    # Enable maintenance on entire node
                    /usr/local/bin/consul maint -enable -reason "$(date +%FT%T) - $REASON"
                    exit $?
                    ;;
                *)
                    # Enable maintenance on specific service
                    /usr/local/bin/consul maint -enable -service $service -reason "$(date +%FT%T) - $REASON"
                    exit $?
                    ;;
            esac
        done
    fi
else
    /usr/local/bin/consul maint
    read -p "Do you want to disable above maintenance? (Y/N) : "
    if [ ${REPLY,,} = "y" ]; then
        # Check if maintenance is enabled at node level and disable
        if [[ $(/usr/local/bin/consul maint|grep 'Name' | wc -l) -eq 1 ]]; then
            /usr/local/bin/consul maint -disable
        else
            # Check if maintenance is enabled at service level and disable across all services
            for service in $(/usr/local/bin/consul maint|grep 'ID'|awk '{print $2}'); do
                /usr/local/bin/consul maint -disable -service $service
            done
        fi
    fi
fi

# Find which nodes are serving a specific consul service
# service="consul-service-name"; curl -s "http://127.0.0.1:8500/v1/health/service/${service}?passing=true" |jq .[].Node.Node
