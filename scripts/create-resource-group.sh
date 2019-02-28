#!/bin/bash


# Set the default values for the parameter variables.
DEFAULT_SUBSCRIPTION_ID="736bac69-1352-4801-8b8f-567e37804014"
DEFAULT_RESOURCEGROUP_NAME="TestResourceGroup001"
DEFAULT_DEPLOYMENT_NAME="TestDeployment001"
DEFAULT_RESOURCEGROUP_LOCATION="Central US"
DEFAULT_TEMPLATE_FILE_PATH="templates/resource-group.json"
DEFAULT_PARAMETERS_FILE_PATH="output/parameters.json"


# Read the parameter values from the command line.
echo
echo "Please fill in the following parameters to create a resource group."
echo "Defaults are shown in parenthesis.  <Enter> to accept."
echo

read -p "Subscription Id (\"$DEFAULT_SUBSCRIPTION_ID\"): " SUBSCRIPTION_ID
read -p "Resource Group Name (\"$DEFAULT_RESOURCEGROUP_NAME\"): " RESOURCEGROUP_NAME
read -p "Deployment Name (\"$DEFAULT_DEPLOYMENT_NAME\"): " DEPLOYMENT_NAME
read -p "Resource Group Location (\"$DEFAULT_RESOURCEGROUP_LOCATION\"): " RESOURCEGROUP_LOCATION
read -p "Template File Path (\"$DEFAULT_TEMPLATE_FILE_PATH\"): " TEMPLATE_FILE_PATH
read -p "Parameters File Path (\"$DEFAULT_PARAMETERS_FILE_PATH\"): " PARAMETERS_FILE_PATH
echo


# Assign the default values if the user didn't enter any value.
SUBSCRIPTION_ID="${SUBSCRIPTION_ID:-$DEFAULT_SUBSCRIPTION_ID}"
RESOURCEGROUP_NAME="${RESOURCEGROUP_NAME:-$DEFAULT_RESOURCEGROUP_NAME}"
DEPLOYMENT_NAME="${DEPLOYMENT_NAME:-$DEFAULT_DEPLOYMENT_NAME}"
RESOURCEGROUP_LOCATION="${RESOURCEGROUP_LOCATION:-$DEFAULT_RESOURCEGROUP_LOCATION}"
TEMPLATE_FILE_PATH="${TEMPLATE_FILE_PATH:-$DEFAULT_TEMPLATE_FILE_PATH}"
PARAMETERS_FILE_PATH="${PARAMETERS_FILE_PATH:-$DEFAULT_PARAMETERS_FILE_PATH}"


# Create the Resource Group using the above parameters.
#login to azure using your credentials
az account show 1> /dev/null

if [ $? != 0 ]; then
    az login
fi

#set the default subscription id
az account set --subscription $SUBSCRIPTION_ID

set +e

#Check for existing Resource Group
az group show --name $RESOURCEGROUP_NAME 1> /dev/null

if [ $? != 0 ]; then
    echo "Resource group with name" $RESOURCEGROUP_NAME "could not be found. Creating new resource group..."
    set -e
    (
        set -x
        az group create --name $RESOURCEGROUP_NAME --location "$RESOURCEGROUP_LOCATION" 1> /dev/null
    )
else
    echo "Using existing resource group..."
fi

#Start deployment
echo "Starting deployment..."
(
    set -x
    az group deployment create --name "$DEPLOYMENT_NAME" --resource-group "$RESOURCEGROUP_NAME" --template-file "$TEMPLATE_FILE_PATH" --parameters "@${PARAMETERS_FILE_PATH}"
)

if [ $?  == 0 ]; then
	echo "Template has been successfully deployed"
fi

# Display an output message and end the script.
echo
echo "Resource Group ${RESOURCEGROUP_NAME} created!"
echo