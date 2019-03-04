# Azure Rig

## Components
The Azure Rig makes use of a number of different Azure features including


1. Azure Resource Groups and ARM templates
1. Azure Web Apps
1. Azure Kubernetes Service
1. Azure Container Registry
1. Azure SQL Database
1. Azure DevOps Pipeline

## Infrastructure

The Azure Rig comes in two varieties, both making use of containerized applications

1. Azure Web Apps (with containers)
1.  Azure Kubernets Services

## Database

The Azure Rig supports two database options at present

1. An Azure SQL Database can be provisioned in the resource group
1. Deploy SQL Server Container to AKS cluster with persisted volumn

## Azure DevOps Pipeline

This repository contains YAML files for povisioning pipelines for both flavors of the Rig (Azure Web App and Azure Kubernetes Service)

The high level steps for these pipelines: 
1. Build and containerize the application
1. Push the container image to Azure Container Registry 
1. Deploy the Container Images from the Container Registry to the Azure service

## Connect to Azure Devops Services API
In order to create build and release pipelines the Azure DevOps Services REST API must be used [API Documentation](https://docs.microsoft.com/en-us/rest/api/azure/devops/?view=azure-devops-rest-5.0)
### Authorize requests for Azure 
A personal access token (PAT) is required to authorize API requests to grant a PAT follow these steps
1. Go to https://dev.azure.com/<organization> to get to the DevOps organization homepage
1. Click on your user icon in the top right corner and click the security tab from the dropdown menu
1. Click new token and provide a unique name and access scope 
1. Copy and store the token in a secure location

sample command (username is normally the email address of the user)

```curl -u username:<personalaccesstoken> "https://dev.azure.com/<organization>/_apis/projects?api-version=5.0"```

### Authorize requests for Github
A PAT for the Azure pipeline to access github must be created and added to the project
1. Sign into https://github.com/settings/tokens
1. Click generate new token with the scopes -- repo, read:user, user:email, admin:repo_hook
1. Copy and store the token in a secure location

