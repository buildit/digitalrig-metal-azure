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


# Get parameter values from the parameters.json file and inject them into the data file.
SUBSCRIPTION_ID=$(jq -r '.parameters.subscription_id.value' < ./output/parameters.json)
RESOURCEGROUP_NAME=$(jq -r '.parameters.commonResourceGroupName.value' < ./output/parameters.json)
RESOURCEGROUP_LOCATION=$(jq -r '.parameters.commonResourceGroupLocation.value' < ./output/parameters.json)
GIT_BRANCH=$(jq -r '.parameters.gitBranch.value' < ./output/parameters.json)

PARAM_FILE="${DATAPATH}/createCommonResourceGroupData.json"
LOWER_RESOURCEGROUP_NAME=$(echo "$RESOURCEGROUP_NAME" | awk '{print tolower($0)}')
COMMON_STORAGEACCOUNT_NAME="${LOWER_RESOURCEGROUP_NAME}stgacc"
COMMON_CONTAINERREGISTRY_NAME="${LOWER_RESOURCEGROUP_NAME}containerregistry"
COMMON_CONTAINERREGISTRY_URL="${COMMON_CONTAINERREGISTRY_NAME}.azurecr.io"
COMMON_RESOURCEGROUP_LOCATION="${RESOURCEGROUP_LOCATION}"

sed -i'' -e "s/COMMON_STORAGEACCOUNT_NAME/${COMMON_STORAGEACCOUNT_NAME}/g" $PARAM_FILE
sed -i'' -e "s/COMMON_CONTAINERREGISTRY_NAME/${COMMON_CONTAINERREGISTRY_NAME}/g" $PARAM_FILE
sed -i'' -e "s/COMMON_RESOURCEGROUP_LOCATION/${COMMON_RESOURCEGROUP_LOCATION}/g" $PARAM_FILE


# Login to azure using your credentials.
LOGININFO=$(az account show)
if [[ -z $LOGININFO ]]; then LOGININFO=$(az login); fi


# Create or get info for Resource Group.
RESOURCEINFO=$(az group create --name $RESOURCEGROUP_NAME --location "$RESOURCEGROUP_LOCATION")
COMMON_RESOURCEGROUP_ID=$(echo "$RESOURCEINFO" | jq -r '.id')


# Executes a Deployment to create the resources.
az group deployment create \
    --name "${RESOURCEGROUP_NAME}Deployment001" \
    --resource-group "$RESOURCEGROUP_NAME" \
    --template-file "$PARAM_FILE"


# Gets the Storage Account Key
STORAGEACCOUNT_KEYINFO=$(az storage account keys list \
    --resource-group "$RESOURCEGROUP_NAME" \
    --account-name "$COMMON_STORAGEACCOUNT_NAME")
COMMON_STORAGEACCOUNT_KEY=$(echo $STORAGEACCOUNT_KEYINFO | jq -r '.[] | select(.keyName == "key1") | .value')


# Creates a new storage blob container.
CLEAN_GIT_BRANCH=$(echo "${GIT_BRANCH//\//-}" | awk '{print tolower($0)}')
CONTAINER_NAME="${CLEAN_GIT_BRANCH}-test-results"
az storage container create \
    --name $CONTAINER_NAME \
    --account-key $COMMON_STORAGEACCOUNT_KEY \
    --account-name $COMMON_STORAGEACCOUNT_NAME \
    --subscription $SUBSCRIPTION_ID


# Saves the container URL and the storage account key in the parameters.json file.
PARAM_FILE="output/parameters.json"
COMMON_STORAGEACCOUNT_CONTAINER_URL="https://${COMMON_STORAGEACCOUNT_NAME}.blob.core.windows.net/${CONTAINER_NAME}"
sed -i'' -e "s~COMMON_RESOURCEGROUP_ID~${COMMON_RESOURCEGROUP_ID}~g" $PARAM_FILE
sed -i'' -e "s~COMMON_STORAGEACCOUNT_NAME~${COMMON_STORAGEACCOUNT_NAME}~g" $PARAM_FILE
sed -i'' -e "s~COMMON_STORAGEACCOUNT_KEY~${COMMON_STORAGEACCOUNT_KEY}~g" $PARAM_FILE
sed -i'' -e "s~COMMON_STORAGEACCOUNT_CONTAINER_URL~${COMMON_STORAGEACCOUNT_CONTAINER_URL}~g" $PARAM_FILE
sed -i'' -e "s~COMMON_CONTAINERREGISTRY_URL~${COMMON_CONTAINERREGISTRY_URL}~g" $PARAM_FILE

echo "Common Resource Group ${RESOURCEGROUP_NAME} created or exists!"
