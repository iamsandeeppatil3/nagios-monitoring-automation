#!/bin/bash

###############################################################################
# Script Name : nagios_docker_service_generator.sh
# Author      : Sandeep Patil
# Version     : 1.0
# Created     : 2026-06-08
# Updated     : 2026-06-08
#
# Purpose:
#   Discovers Docker containers running on monitored Linux servers via NRPE
#   and automatically generates Nagios service definitions for container
#   health monitoring.
#
# Features:
#   - Collects monitored hosts from Nagios configuration files
#   - Retrieves Docker container names remotely using NRPE
#   - Generates service definitions automatically
#   - Validates Nagios configuration before deployment
#   - Supports bulk onboarding of Docker-based services
#
# Requirements:
#   - Nagios Core
#   - NRPE
#   - Docker
#   - Bash 4+
#
# Usage:
#   ./nagios_docker_service_generator.sh
#
###############################################################################

set -o errexit
set -o nounset
set -o pipefail

###############################################################################
# Configuration
###############################################################################

INVENTORY_FILE="/path/to/inventory"
HOST_CONFIG_DIR="/path/to/nagios/hosts"
OUTPUT_DIR="/path/to/generated/service-definitions"
NAGIOS_CONFIG="/path/to/nagios.cfg"

###############################################################################
# Build Host Inventory
###############################################################################

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
    echo "Discovering containers on ${host}..."

    containers=$(
        /usr/local/nagios/libexec/check_nrpe \
            -H "$ip" \
            -c list_docker_containers \
            2>/dev/null \
            | grep -v "NRPE:"
    )

    if [[ -z "$containers" ]]; then
        echo "No containers found or NRPE unavailable on ${host}"
        continue
    fi

    cfg_file="${OUTPUT_DIR}/${host}_docker-containers"

    : > "$cfg_file"

    for container in $containers
    do
        cat >> "$cfg_file" <<EOF
define service{
        use                             generic-service
        host_name                       ${host}
        service_description             ${container} container
        check_command                   check_nrpe!check_${container}
        notification_interval           15
        check_interval                  1
}
EOF
    done

    echo "Generated service definitions for ${host}"

done < "$INVENTORY_FILE"

###############################################################################
# Rename Generated Files
###############################################################################

for file in "$OUTPUT_DIR"/*_docker-containers
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
