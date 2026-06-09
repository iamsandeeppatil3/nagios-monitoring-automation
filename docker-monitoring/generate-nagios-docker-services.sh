#!/bin/bash

###############################################################################
# Script Name : generate-nrpe-docker-checks.sh
# Author      : Sandeep Patil
# Version     : 1.0
# Created     : 2025-01-01
# Updated     : 2026-06-08
#
# Purpose:
#   Automatically generates NRPE command definitions for all Docker
#   containers present on the host.
#
# Features:
#   - Discovers Docker containers automatically
#   - Generates NRPE command definitions
#   - Creates or overwrites NRPE Docker configuration
#   - Restarts NRPE service
#
# Requirements:
#   - Docker
#   - NRPE
#   - Nagios Docker check plugin
#
# Usage:
#   ./generate-nrpe-docker-checks.sh
#
###############################################################################

set -o errexit
set -o nounset
set -o pipefail

###############################################################################
# Configuration
###############################################################################

NRPE_CONFIG_FILE="/etc/nagios/nrpe.d/docker.cfg"
DOCKER_CHECK_PLUGIN="/usr/lib/nagios/plugins/check_docker"

###############################################################################
# Validation
###############################################################################

if ! command -v docker >/dev/null 2>&1
then
    echo "Docker is not installed."
    exit 1
fi

if [[ ! -x "$DOCKER_CHECK_PLUGIN" ]]
then
    echo "Docker check plugin not found: $DOCKER_CHECK_PLUGIN"
    exit 1
fi

###############################################################################
# Generate NRPE Commands
###############################################################################

echo "Generating NRPE Docker checks..."

> "$NRPE_CONFIG_FILE"

docker ps -a --format '{{.Names}}' | while read -r container
do
    [[ -z "$container" ]] && continue

    echo "command[check_${container}]=$DOCKER_CHECK_PLUGIN $container" \
        >> "$NRPE_CONFIG_FILE"
done

###############################################################################
# Restart NRPE
###############################################################################

echo "Restarting NRPE service..."

if systemctl list-unit-files | grep -q "^nagios-nrpe-server"
then
    systemctl restart nagios-nrpe-server
    systemctl status nagios-nrpe-server --no-pager
elif systemctl list-unit-files | grep -q "^nrpe"
then
    systemctl restart nrpe
    systemctl status nrpe --no-pager
else
    echo "NRPE service not found."
    exit 1
fi

echo
echo "NRPE Docker check generation completed."
