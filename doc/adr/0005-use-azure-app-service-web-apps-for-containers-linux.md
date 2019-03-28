# 5. Use Azure App Service - Web Apps for Containers Linux

Date: 2019-03-27

## Status

Accepted

## Context

The Azure Rig needs a compute service to run our Docker containers.  Azure provides a number of options:

* Azure Application Services - Web Apps for Containers
* Azure Kubernetes Service
* Azure Container Instances
* Azure Service Fabric

As the Rig evolves, it should allow the operators to choose which compute resources they want.

## Decision

We will use the Azure Applicaiton Services - Web Apps for Containers in Linux.  We plan on 1 App Service Plan per Environment (shared across application instances)

## Consequences

* We assume all applications that use this Rig will expose HTTP/S endpoints and run in Linux based Docker containers.
* Linux based App Services don't have console integration with Application Insights.
* The App Services plan that supports Virutal Networking (Isolated) is quite expensive
* App Services support Custom Domains & SSL
* Based on the chosen plan, they also support manual/auto scaling, slots (green/blue), backups