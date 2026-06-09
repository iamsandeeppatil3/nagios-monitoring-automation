#!/bin/bash

###############################################################################
# Script Name : nrpe_docker_command_generator.sh
# Author      : Sandeep Patil
# Version     : 1.0
# Created     : 2026-06-08
# Updated     : 2026-06-08
#
# Purpose:
# Automatically generates NRPE command definitions for all Docker
# containers present on a Linux server, enabling container-level
# monitoring from Nagios.
#
# Features:
# - Discovers all Docker containers
# - Creates NRPE command definitions automatically
# - Eliminates manual NRPE configuration updates
# - Restarts NRPE service after configuration changes
#
# Requirements:
# - Docker
# - NRPE
# - Nagios Plugins
#
# Usage:
# ./nrpe_docker_command_generator.sh
#
###############################################################################

set -o errexit
set -o nounset
set -o pipefail

###############################################################################

# Configuration

###############################################################################

NRPE_CONFIG_FILE="/etc/nagios/nrpe.d/docker.cfg"
DOCKER_PLUGIN="/usr/lib/nagios/plugins/check_docker"

###############################################################################

# Validate Requirements

###############################################################################

if ! command -v docker >/dev/null 2>&1
then
echo "Docker is not installed."
exit 1
fi

###############################################################################

# Generate NRPE Commands

###############################################################################

echo "Generating NRPE Docker monitoring configuration..."

: > "$NRPE_CONFIG_FILE"

docker ps -a --format '{{.Names}}' | while read -r container_name
do
[[ -z "$container_name" ]] && continue

```
echo "command[check_${container_name}]=${DOCKER_PLUGIN} ${container_name}" \
    >> "$NRPE_CONFIG_FILE"
```

done

###############################################################################

# Restart NRPE Service

###############################################################################

echo "Restarting NRPE service..."

systemctl restart nagios-nrpe-server

###############################################################################

# Verify Service Status

###############################################################################

if systemctl is-active --quiet nagios-nrpe-server
then
echo "NRPE service restarted successfully."
else
echo "NRPE service failed to start."
exit 1
fi

echo "Docker monitoring configuration completed."
