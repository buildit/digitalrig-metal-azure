# Azure Rig

##Components
The Azure Rig makes use of a number of different Azure features including


1. Azure Resource Groups and ARM templates
1. Azure Web Apps
1. Azure Kubernetes Service
1. Azure Container Registry
1. Azure SQL Database
1. Azure DevOps Pipeline

##Infrastructure

The Azure Rig comes in two varieties, both making use of containerized applications

1. Azure Web Apps (with containers)
1.  Azure Kubernets Services

##Database

The Azure Rig supports two database options at present

1. An Azure SQL Database can be provisioned in the resource group
1. Deploy SQL Server Container to AKS cluster with persisted volumn

##Azure DevOps Pipeline

This repository contains YAML files for povisioning pipelines for both flavors of the Rig (Azure Web App and Azure Kubernetes Service)

The high level steps for these pipelines: 
1. Build and containerize the application
1. Push the container image to Azure Container Registry 
1. Deploy the Container Images from the Container Registry to the Azure service


