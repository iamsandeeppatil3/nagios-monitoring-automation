# Docker Monitoring Automation

## Overview

Automation for onboarding Docker containers into Nagios monitoring.

## Components

### generate-nrpe-docker-checks.sh

Runs on monitored Linux hosts and automatically generates NRPE command definitions for Docker containers.

### generate-nagios-docker-services.sh

Runs on the Nagios server and automatically generates service definitions for discovered Docker containers.

## Workflow

1. Discover Docker containers.
2. Generate NRPE command definitions.
3. Generate Nagios service definitions.
4. Validate Nagios configuration.
5. Reload Nagios.

## Benefits

* Reduced manual monitoring configuration
* Faster onboarding of containerized workloads
* Consistent monitoring standards

## Technologies

* Docker
* Nagios
* NRPE
* Bash
