#! /bin/bash

DATAPATH=./scripts/createReleasePipeline/data
OUTPUTPATH=./scripts/createReleasePipeline/outputs
TEMPLATEPATH=./scripts/createReleasePipeline/templates
mkdir -p $DATAPATH
mkdir -p $OUTPUTPATH
mkdir -p $TEMPLATEPATH

# variables defined in parameters
VERSIONHASH=$(jq -r '.parameters.versionHash.value' < ./output/parameters.json)
BASERESOURCEGROUPNAME=$(jq -r '.parameters.resourceGroupName.value' < ./output/parameters.json)
LOCATION=$(jq -r '.parameters.location.value' < ./output/parameters.json)
DEVOPSUSER=$(jq -r '.parameters.devops_user.value' < ./output/parameters.json)
DEVOPSPAT=$(jq -r '.parameters.devops_PAT.value' < ./output/parameters.json)
DEVOPSOWNER=$(jq -r '.parameters.devops_owner.value' < ./output/parameters.json)
USERCRED=$DEVOPSUSER:$DEVOPSPAT
ORGNAME=$(jq -r '.parameters.devops_org_name.value' < ./output/parameters.json)
PROJECTNAME=$(jq -r '.parameters.devops_proj_name.value' < ./output/parameters.json)
PROJECTID=$(jq -r '.parameters.devops_proj_id.value' < ./output/parameters.json)
SERVICECONNECTIONID=$(jq -r '.parameters.serviceConnectionId.value' < ./output/parameters.json)
GITHUBSERVICECONNECTIONID=$(jq -r '.parameters.gitHubServiceConnectionId.value' < ./output/parameters.json)
GITHUBSERVICECONNECTIONNAME=$(jq -r '.parameters.gitHubServiceConnectionName.value' < ./output/parameters.json)
BASEAPPNAME=$BASERESOURCEGROUPNAME"App"  #$(jq -r '.parameters.sites_RigContainerApp_name.value' < ./output/parameters.json)
OWNER_ID=$(jq -r '.parameters.ownerId.value' < ./output/parameters.json)
COMMON_STORAGEACCOUNT_NAME=$(jq -r '.parameters.commonStorageAccountName.value' < ./output/parameters.json)
COMMON_STORAGEACCOUNT_KEY=$(jq -r '.parameters.commonStorageAccountKey.value' < ./output/parameters.json)
COMMON_CONTAINERREGISTRY_URL=$(jq -r '.parameters.commonContainerRegistryName.value' < ./output/parameters.json)"azurecr.io"

#create release pipelines
echo "creating dev release pipeline"
DATAFILE=createDevReleasePipelineData.json
TEMPLATEFILE=createReleasePipelineTemplate.json
OUTPUTFILE=createDevReleaseOutput.json
[ -e $DATAPATH/$DATAFILE ] && rm $DATAPATH/$DATAFILE
[ -e $OUTPUTPATH/$OUTPUTFILE ] && rm $OUTPUTPATH/$OUTPUTFILE
cp $TEMPLATEPATH/$TEMPLATEFILE $DATAPATH/$DATAFILE

LOWERRESOURCEGROUPNAME=$(echo "$BASERESOURCEGROUPNAME" | awk '{print tolower($0)}')
REGISTRYNAME=$LOWERRESOURCEGROUPNAME"acr"
REGISTRYADDRESS=$REGISTRYNAME".azurecr.io"

STAGE="DEV"
PIPELINENAME="$STAGE New Pipeline-"$VERSIONHASH
SOURCEPIPELINEID=$(jq -r '.parameters.devPipelineId.value' < ./output/parameters.json)
SOURCEPIPELINENAME=$(jq -r '.parameters.devPipelineName.value' < ./output/parameters.json)
IMAGENAME="azurerig"
IMAGENAME=$(echo "$IMAGENAME" | awk '{print tolower($0)}')
APPNAME=$BASEAPPNAME$STAGE
RESOURCEGROUPNAME=$BASERESOURCEGROUPNAME$STAGE
STAGE_LOWERCASE=$(echo "$STAGE" | awk '{print tolower($0)}')
COMMON_STORAGEACCOUNT_CONTAINER_NAME="$STAGE_LOWERCASE-test-results"
COMMON_STORAGEACCOUNT_CONTAINER_URL="https://${COMMON_STORAGEACCOUNT_NAME}.blob.core.windows.net/${COMMON_STORAGEACCOUNT_CONTAINER_NAME}"
APPNAME_LOWERCASE=$(echo "$APPNAME" | awk '{print tolower($0)}')
SLACKBOT_HELLO_URL="https://${APPNAME_LOWERCASE}.azurewebsites.net/"
GITORG=$(jq -r '.parameters.gitOrg.value' < ./output/parameters.json)
GITREPO=$(jq -r '.parameters.gitRepo.value' < ./output/parameters.json)

sed -i'' -e " s|\${serviceConnectionId}|$SERVICECONNECTIONID|g; s|\${resourceGroupName}|$RESOURCEGROUPNAME|g; s|\${location}|$LOCATION|g; s|\${registryName}|$REGISTRYNAME|g; s|\${registryAddress}|$REGISTRYADDRESS|g; s|\${appName}|$APPNAME|g; s|\${registrySku}|$REGISTRYSKU|g; s|\${imageName}|$IMAGENAME|g; s|\${orgName}|$ORGNAME|g; s|\${pipelineName}|$PIPELINENAME|g; s|\${pipelineId}|$SOURCEPIPELINEID|g" $DATAPATH/$DATAFILE
sed -i'' -e " s|\${OWNER_ID}|$OWNER_ID|g; s|\${sourcePipelineName}|$SOURCEPIPELINENAME|g; s|\${projectId}|$PROJECTID|g" $DATAPATH/$DATAFILE
sed -i'' -e " s|STORAGE_ACCOUNT_KEY|$COMMON_STORAGEACCOUNT_KEY|g; s|STORAGE_ACCOUNT_NAME|$COMMON_STORAGEACCOUNT_NAME|g; s|STORAGE_ACCOUNT_URL|$COMMON_STORAGEACCOUNT_CONTAINER_URL|g; s|STORAGE_ACCOUNT_CONTAINER_NAME|$COMMON_STORAGEACCOUNT_CONTAINER_NAME|g; s|SLACKBOT_HELLOWORLD_URL|$SLACKBOT_HELLO_URL|g;" $DATAPATH/$DATAFILE
sed -i'' -e " s|\${gitOrg}|$GITORG|g; s|\${gitRepo}|$GITREPO|g; s|\${gitHubServiceConnectionId}|$GITHUBSERVICECONNECTIONID|g; s|\${gitHubServiceConnectionName}|$GITHUBSERVICECONNECTIONNAME|g;" $DATAPATH/$DATAFILE

until $(curl -u $USERCRED --header "Content-Type: application/json" --request POST --data "@$DATAPATH/$DATAFILE" "https://vsrm.dev.azure.com/$ORGNAME/$PROJECTNAME/_apis/release/definitions?api-version=5.0" | jq '.' > $OUTPUTPATH/createDevReleaseOutput.json); do
    printf "wating to create pipeline"
    sleep 5
done

echo "creating prod release pipeline"
DATAFILE=createProdReleasePipelineData.json
TEMPLATEFILE=createProdReleasePipelineTemplate.json
OUTPUTFILE=createProdReleaseOutput.json
[ -e $DATAPATH/$DATAFILE ] && rm $DATAPATH/$DATAFILE
[ -e $OUTPUTPATH/$OUTPUTFILE ] && rm $OUTPUTPATH/$OUTPUTFILE
cp $TEMPLATEPATH/$TEMPLATEFILE $DATAPATH/$DATAFILE

STAGE="PROD"
PIPELINENAME="$STAGE New Pipeline-"$VERSIONHASH
SOURCEPIPELINEID=$(jq -r '.parameters.prodPipelineId.value' < ./output/parameters.json)
SOURCEPIPELINENAME=$(jq -r '.parameters.prodPipelineName.value' < ./output/parameters.json)
IMAGENAME="azurerig"
APPNAME=$BASEAPPNAME
RESOURCEGROUPNAME=$BASERESOURCEGROUPNAME$STAGE
STAGE_LOWERCASE=$(echo "$STAGE" | awk '{print tolower($0)}')
COMMON_STORAGEACCOUNT_CONTAINER_NAME="$STAGE_LOWERCASE-test-results"

STAGE1="STAGE"
STAGE2="PROD"
sed -i'' -e " s|\${serviceConnectionId}|$SERVICECONNECTIONID|g; s|\${resourceGroupName}|$RESOURCEGROUPNAME|g; s|\${location}|$LOCATION|g; s|\${registryName}|$REGISTRYNAME|g; s|\${appName}|$APPNAME|g; s|\${registrySku}|$REGISTRYSKU|g; s|\${imageName}|$IMAGENAME|g; s|\${orgName}|$ORGNAME|g; s|\${pipelineName}|$PIPELINENAME|g; s|\${pipelineId}|$SOURCEPIPELINEID|g" $DATAPATH/$DATAFILE
sed -i'' -e " s|\${OWNER_ID}|$OWNER_ID|g; s|\${sourcePipelineName}|$SOURCEPIPELINENAME|g; s|\${projectId}|$PROJECTID|g; s|\${stage1}|$STAGE1|g; s|\${stage2}|$STAGE2|g" $DATAPATH/$DATAFILE
sed -i'' -e " s|STORAGE_ACCOUNT_KEY|$COMMON_STORAGEACCOUNT_KEY|g; s|STORAGE_ACCOUNT_NAME|$COMMON_STORAGEACCOUNT_NAME|g; s|STORAGE_ACCOUNT_URL|$COMMON_STORAGEACCOUNT_CONTAINER_URL|g; s|STORAGE_ACCOUNT_CONTAINER_NAME|$COMMON_STORAGEACCOUNT_CONTAINER_NAME|g;" $DATAPATH/$DATAFILE
until $(curl -u $USERCRED --header "Content-Type: application/json" --request POST --data "@$DATAPATH/$DATAFILE" "https://vsrm.dev.azure.com/$ORGNAME/$PROJECTNAME/_apis/release/definitions?api-version=5.0" | jq '.' > $OUTPUTPATH/createProdReleaseOutput.json); do
    printf "wating to create pipeline"
    sleep 5
done
