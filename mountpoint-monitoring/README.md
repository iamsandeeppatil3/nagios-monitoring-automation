# Mount Point Monitoring Automation

## Overview

Automation for onboarding filesystem mount points into Nagios monitoring.

## Components

### generate-nagios-mountpoint-services.sh

Discovers filesystem mount points through NRPE and automatically generates Nagios service definitions.

## Workflow

1. Discover mount points.
2. Generate service definitions.
3. Validate Nagios configuration.
4. Reload Nagios.

## Benefits

* Automated filesystem monitoring onboarding
* Reduced manual configuration effort
* Consistent monitoring coverage

## Technologies

* Nagios
* NRPE
* Bash
* Linux
