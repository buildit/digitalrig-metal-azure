# Azure Rig

This repository contains code to create and maintain a simple Rig implementation on Azure. Most of the technologies used for this Rig implementation are provided by Microsoft Azure in the way of a platform as a service way. 

## Features

The Azure Rig makes use of a number of different Azure features including:

1. Azure Resource Groups
1. Azure Resource Manager templates (ARM)
1. Azure Web Apps
1. Azure Kubernetes Services (formerly known as Azure Container Service)
1. Azure Container Registries
1. Azure SQL Databases
1. Azure DevOps Pipelines

## Components

The major components of this Rig are:

1. A foundational resource group
1. A build pipeline
1. A release pipeline
1. An app environment provided by Azure Kubernetes Services

## Infrastructure

The Azure Rig comes in two varieties, both making use of containerized applications:

1. Azure Web Apps (with containers)
1. Azure Kubernets Services

## Database

The Azure Rig supports two database options at present:

1. An Azure SQL Database can be provisioned in the resource group.
1. Deploy SQL Server Container to AKS cluster with persisted volumn.

## Azure DevOps Pipeline

This repository contains YAML files for provisioning pipelines for both flavors of the Rig (Azure Web App and Azure Kubernetes Service)

The high level steps for these pipelines: 

1. Build and containerize the application.
1. Push the container image to Azure Container Registry.
1. Deploy the Container Images from the Container Registry to the Azure service.

## Connect to Azure Devops Services API

In order to create build and release pipelines, the Azure DevOps Services REST API must be used [API Documentation](https://docs.microsoft.com/en-us/rest/api/azure/devops/?view=azure-devops-rest-5.0)

### Authorize requests for Azure 

A Personal Access Token (PAT) is required to authorize API requests. To grant a PAT follow these steps:

1. Go to https://dev.azure.com/{organization} to get to the DevOps organization homepage.
1. Click on your user icon in the top right corner and click the security tab from the dropdown menu.
1. Click new token and provide a unique name and access scope.
1. Copy and store the token in a secure location.

sample command (username is normally the email address of the user)
{personalaccesstoken} is the PAT obtained from the steps above.
{organization} is the name of the organization implementing the rig.

```curl -u username:{personalaccesstoken} "https://dev.azure.com/{organization}/_apis/projects?api-version=5.0"```

### Authorize requests for Github

A PAT for the Azure pipeline to access github must be created and added to the project:

1. Sign into https://github.com/settings/tokens .
1. Click generate new token with the scopes -- repo, read:user, user:email, admin:repo_hook .
1. Copy and store the token in a secure location.
