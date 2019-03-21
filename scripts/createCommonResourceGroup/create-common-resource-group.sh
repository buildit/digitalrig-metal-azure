#!/bin/bash

# Creates the folder structure to run this script.
DATAPATH=./scripts/createCommonResourceGroup/data
OUTPUTPATH=./scripts/createCommonResourceGroup/outputs
TEMPLATEPATH=./scripts/createCommonResourceGroup/templates

mkdir -p $DATAPATH
mkdir -p $OUTPUTPATH
mkdir -p $TEMPLATEPATH

[ -e $DATAPATH/createCommonResourceGroupData.json ] && rm $DATAPATH/createCommonResourceGroupData.json
[ -e $OUTPUTPATH/createCommonResourceGroupOutput.json ] && rm $OUTPUTPATH/createCommonResourceGroupOutput.json
cp $TEMPLATEPATH/createCommonResourceGroupTemplate.json $DATAPATH/createCommonResourceGroupData.json

# Login to azure using your credentials.
LOGININFO=$(az account show)
if [[ -z $LOGININFO ]]; then LOGININFO=$(az login); fi

SUBSCRIPTIONID=$(echo "$LOGININFO" | jq -r '.id')
SUBSCRIPTIONNAME=$(echo "$LOGININFO" | jq -r '.name')
TENANTID=$(echo "$LOGININFO" | jq -r '.tenantId')

# Get parameter values from the parameters.json file and inject them into the data file.
RESOURCEGROUP_NAME=$(jq -r '.parameters.resourceGroupName.value' < ./output/parameters.json)
RESOURCEGROUP_LOCATION=$(jq -r '.parameters.location.value' < ./output/parameters.json)

DATA_FILE="${DATAPATH}/createCommonResourceGroupData.json"
LOWER_RESOURCEGROUP_NAME=$(echo "$RESOURCEGROUP_NAME" | awk '{print tolower($0)}')
COMMON_STORAGEACCOUNT_NAME="${LOWER_RESOURCEGROUP_NAME}stgacc"
COMMON_CONTAINERREGISTRY_NAME="${LOWER_RESOURCEGROUP_NAME}acr"

sed -i'' -e "s/COMMON_STORAGEACCOUNT_NAME/${COMMON_STORAGEACCOUNT_NAME}/g" $DATA_FILE
sed -i'' -e "s/COMMON_CONTAINERREGISTRY_NAME/${COMMON_CONTAINERREGISTRY_NAME}/g" $DATA_FILE
sed -i'' -e "s/COMMON_RESOURCEGROUP_LOCATION/${RESOURCEGROUP_LOCATION}/g" $DATA_FILE


# Create or get info for Resource Group.
RESOURCEINFO=$(az group create --name $RESOURCEGROUP_NAME --location "$RESOURCEGROUP_LOCATION")
RESOURCEGROUPID=$(echo "$RESOURCEINFO" | jq -r '.id')

# Executes a Deployment to create the resources.
az group deployment create \
    --name "${RESOURCEGROUP_NAME}Deployment001" \
    --resource-group "$RESOURCEGROUP_NAME" \
    --template-file "$DATA_FILE"

# Gets the Storage Account Key
STORAGEACCOUNT_KEYINFO=$(az storage account keys list \
    --resource-group "$RESOURCEGROUP_NAME" \
    --account-name "$COMMON_STORAGEACCOUNT_NAME")
COMMON_STORAGEACCOUNT_KEY=$(echo $STORAGEACCOUNT_KEYINFO | jq -r '.[] | select(.keyName == "key1") | .value')


# Saves the container URL and the storage account key in the parameters.json file.
PARAM_FILE="output/parameters.json"
sed -i'' -e "s~COMMON_STORAGEACCOUNT_NAME~${COMMON_STORAGEACCOUNT_NAME}~g" $PARAM_FILE
sed -i'' -e "s~COMMON_STORAGEACCOUNT_KEY~${COMMON_STORAGEACCOUNT_KEY}~g" $PARAM_FILE
sed -i'' -e "s~COMMON_CONTAINERREGISTRY_NAME~${COMMON_CONTAINERREGISTRY_NAME}~g" $PARAM_FILE

sed -i'' -e "s/SUBSCRIPTIONID/${SUBSCRIPTIONID}/g" $PARAM_FILE
sed -i'' -e "s/SUBSCRIPTIONNAME/${SUBSCRIPTIONNAME}/g" $PARAM_FILE
sed -i'' -e "s/TENANTID/${TENANTID}/g" $PARAM_FILE
sed -i'' -e "s|\${RESOURCEGROUPID}|$RESOURCEGROUPID|" $PARAM_FILE

echo "Common Resource Group ${RESOURCEGROUP_NAME} created or exists!"





