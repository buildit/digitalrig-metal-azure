#!/bin/bash

# Read the parameter values from the command line.

# Create the Resource Group using the above parameters.
#login to azure using your credentials

LOGININFO=$(az account show)

if [[ -z $LOGININFO ]]; then
    LOGININFO=$(az login)
fi

ACCOUNTID=$(echo "$LOGININFO" | jq -r '.id')
ACCOUNTNAME=$(echo "$LOGININFO" | jq -r '.name')
TENANTID=$(echo "$LOGININFO" | jq -r '.tenantId')

#Create or get info for Resource Group
RESOURCEGROUP_NAME=$(jq -r '.parameters.resourceGroupName.value' < ./output/parameters.json)
RESOURCEGROUP_LOCATION=$(jq -r '.parameters.location.value' < ./output/parameters.json)

RESOURCEINFO=$(az group create --name $RESOURCEGROUP_NAME --location "$RESOURCEGROUP_LOCATION")
RESOURCEGROUPID=$(echo "$RESOURCEINFO" | jq -r '.id')
#add values to parameters
PARAM_FILE="output/parameters.json"

sed -i "s/ACCOUNTID/${ACCOUNTID}/g" $PARAM_FILE
sed -i "s/ACCOUNTNAME/${ACCOUNTNAME}/g" $PARAM_FILE
sed -i "s/TENANTID/${TENANTID}/g" $PARAM_FILE
sed -i "s|\${RESOURCEGROUPID}|$RESOURCEGROUPID|" $PARAM_FILE

echo "Resource Group ${RESOURCEGROUP_NAME} created or exists!"