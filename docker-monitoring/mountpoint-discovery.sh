#!/bin/bash

###############################################################################
# Script Name : nagios_mountpoint_service_generator.sh
# Author      : Sandeep Patil
# Version     : 1.0
# Created     : 2026-06-08
# Updated     : 2026-06-08
#
# Purpose:
#   Discovers filesystem mount points on remote Linux servers through
#   NRPE and automatically generates Nagios service definitions for
#   mount point monitoring.
#
# Features:
#   - Host inventory generation from Nagios configuration
#   - Remote mount point discovery via NRPE
#   - Automatic service definition generation
#   - Configuration validation before deployment
#   - Bulk onboarding of filesystem monitoring checks
#
# Requirements:
#   - Nagios Core
#   - NRPE
#   - Bash 4+
#
# Usage:
#   ./nagios_mountpoint_service_generator.sh
#
###############################################################################

set -o errexit
set -o nounset
set -o pipefail

###############################################################################
# Configuration
###############################################################################

INVENTORY_FILE="./inventory"
HOST_CONFIG_DIR="/path/to/nagios/host-configs"
OUTPUT_DIR="./generated-configs"
NAGIOS_CONFIG="/path/to/nagios.cfg"

###############################################################################
# Build Host Inventory
###############################################################################

echo "Building inventory..."

grep -rE "address|alias" \
    --include="*.cfg" \
    "$HOST_CONFIG_DIR" \
    | awk '{print $NF}' \
    | paste - - \
    | awk '{print $2, $1}' \
    > "$INVENTORY_FILE"

###############################################################################
# Generate Service Definitions
###############################################################################

while read -r ip host
do
    echo "Discovering mount points on ${host}..."

    mountpoints=$(
        /usr/local/nagios/libexec/check_nrpe \
            -H "$ip" \
            -c check_get_mountpoint_list \
            2>/dev/null
    )

    if [[ -z "$mountpoints" ]]
    then
        echo "No mount points discovered on ${host}"
        continue
    fi

    cfg_file="${OUTPUT_DIR}/${host}_mount-points"

    : > "$cfg_file"

    while read -r filesystem_type mountpoint
    do
        [[ -z "$filesystem_type" ]] && continue

        mountpoint_name=$(echo "$mountpoint" | sed 's/\//_/g')

        cat >> "$cfg_file" <<EOF
define service{
        use                             generic-service
        host_name                       ${host}
        service_description             Mountpoint ${mountpoint}
        check_command                   check_nrpe!check${mountpoint_name}
        notification_interval           15
        check_interval                  1
}
EOF

    done <<< "$mountpoints"

    echo "Generated monitoring configuration for ${host}"

done < "$INVENTORY_FILE"

###############################################################################
# Rename Generated Files
###############################################################################

for file in "$OUTPUT_DIR"/*_mount-points
do
    [[ -f "${file}.cfg" ]] || mv "$file" "${file}.cfg"
done

###############################################################################
# Validate Nagios Configuration
###############################################################################

echo "Validating Nagios configuration..."

if /usr/local/nagios/bin/nagios -v "$NAGIOS_CONFIG"
then
    echo "Validation successful."
    echo "Nagios configuration is ready for reload."
else
    echo "Validation failed."
    exit 1
fi
