# Nagios Monitoring Automation

Collection of automation utilities for onboarding and managing monitoring configurations in Nagios environments.

## Overview

This repository contains Bash-based automation developed to reduce manual monitoring configuration effort and accelerate onboarding of Linux infrastructure into Nagios.

The automations focus on dynamic discovery of monitored resources and automatic generation of Nagios service definitions.

## Projects

### Docker Monitoring

Automates Docker container monitoring by:

* Discovering running containers
* Generating NRPE command definitions
* Generating Nagios service definitions
* Validating monitoring configurations

### Mount Point Monitoring

Automates filesystem monitoring by:

* Discovering mounted filesystems
* Generating Nagios service definitions
* Validating monitoring configurations

## Technologies

* Nagios
* NRPE
* Bash
* Linux
* Docker

## Skills Demonstrated

* Monitoring Automation
* Service Discovery
* Observability
* Linux Administration
* Bash Scripting
* Nagios Administration

## Repository Structure

```text
nagios-monitoring-automation/
├── docker-monitoring/
├── mountpoint-monitoring/
└── docs/
```
