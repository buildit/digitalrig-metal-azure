# 2. Use Azure Bare Metal Rig approach

Date: 2019-03-27

## Status

Accepted

## Context

We need to create an Azure based riglet so we learn about Azure capabilities and have a reference when we walk into clients who use Azure.

## Decision

We will use a Bare Metal Riglet approach similar to the [AWS Bare Metal Rig](https://github.com/buildit/digitalrig-metal-aws).  

Technologies:

* Azure: ACR, Storage Accounts, App Services - Web Sites for Containers, Application Insights
* Deployment Mechanism: Docker images
* Build: Azure DevOps
* Rig creation/deletion: Makefiles, Bash scripts, Azure CLI

## Consequences

* This will tie us to the Azure platform.
* Depending on the effort, Makefiles and bash scripts might not be the right fit.  Consider writing code instead of scripts
