#! /bin/bash

#hash to identifty build pipeline resources
HASH=$( cat /dev/urandom | env LC_CTYPE=C tr -dc a-zA-Z0-9 | head -c 6 ; echo '')
DATAPATH=./scripts/createBuildPipeline/data
OUTPUTPATH=./scripts/createBuildPipeline/outputs
TEMPLATEPATH=./scripts/createBuildPipeline/templates
mkdir -p $DATAPATH
mkdir -p $OUTPUTPATH
mkdir -p $TEMPLATEPATH

# variables defined in parameters
TENNANTID=$(jq -r '.parameters.tenant_id.value' < ./output/parameters.json)
RESOURCEGROUPID=$(jq -r '.parameters.resourceGroupId.value' < ./output/parameters.json)
RESOURCEGROUPNAME=$(jq -r '.parameters.resourceGroupName.value' < ./output/parameters.json)
SUBSCRIPTIONID=$(jq -r '.parameters.subscription_id.value' < ./output/parameters.json)
SUBSCRIPTIONNAME=$(jq -r '.parameters.subscription_name.value' < ./output/parameters.json)
LOCATION=$(jq -r '.parameters.location.value' < ./output/parameters.json)
DEVOPSUSER=$(jq -r '.parameters.devops_user.value' < ./output/parameters.json)
DEVOPSPAT=$(jq -r '.parameters.devops_PAT.value' < ./output/parameters.json)
USERCRED=$DEVOPSUSER:$DEVOPSPAT
ORGNAME=$(jq -r '.parameters.devops_org_name.value' < ./output/parameters.json)
PROJECTNAME=$(jq -r '.parameters.devops_proj_name.value' < ./output/parameters.json)
PROJECTID=$(jq -r '.parameters.devops_proj_id.value' < ./output/parameters.json)
GITPAT=$(jq -r '.parameters.gitPAT.value' < ./output/parameters.json)
GITORG=$(jq -r '.parameters.gitOrg.value' < ./output/parameters.json)
GITREPO=$(jq -r '.parameters.gitRepo.value' < ./output/parameters.json)
COMMON_RESOURCEGROUP_ID=$(jq -r '.parameters.commonResourceGroupId.value' < ./output/parameters.json)
COMMON_STORAGEACCOUNT_NAME=$(jq -r '.parameters.commonStorageAccountName.value' < ./output/parameters.json)
COMMON_STORAGEACCOUNT_KEY=$(jq -r '.parameters.commonStorageAccountKey.value' < ./output/parameters.json)
COMMON_STORAGEACCOUNT_CONTAINER_URL=$(jq -r '.parameters.commonStorageAccountContainerUrl.value' < ./output/parameters.json)
COMMON_CONTAINERREGISTRY_URL=$(jq -r '.parameters.commonContainerRegistryUrl.value' < ./output/parameters.json)

#values that might change in future
REGISTRYSKU="basic"
IMAGENAME="azureImage"

#import values into createServiceConnectionData.json
echo "creating service connection for build tasks"
[ -e $DATAPATH/createServiceConnectionData.json ] && rm $DATAPATH/createServiceConnectionData.json
[ -e $OUTPUTPATH/createServiceOutput.json ] && rm $OUTPUTPATH/createServiceOutput.json
cp $TEMPLATEPATH/createServiceConnectionDataTemplate.json $DATAPATH/createServiceConnectionData.json
SERVICECONNECTIONIDGEN=$(uuidgen)
SERVICECONNECTIONNAME="Azure Service Connection-"$HASH
echo "https://dev.azure.com/$ORGNAME/$PROJECTNAME/_apis/serviceendpoint/endpoints?api-version=5.0-preview.2"
sed -i'' -e "s|\${serviceConnectionId}|$SERVICECONNECTIONIDGEN|; s|\${tennantId}|$TENNANTID|; s|\${resourceGroupId}|$COMMON_RESOURCEGROUP_ID|; s|\${subscriptionId}|$SUBSCRIPTIONID|; s|\${subscriptionName}|$SUBSCRIPTIONNAME|; s|\${connectionName}|$SERVICECONNECTIONNAME|" $DATAPATH/createServiceConnectionData.json
#user credentials should be form username:PAT and defined in config
until $(curl -u $USERCRED --header "Content-Type: application/json" --request POST --data "@$DATAPATH/createServiceConnectionData.json" "https://dev.azure.com/$ORGNAME/$PROJECTNAME/_apis/serviceendpoint/endpoints?api-version=5.0-preview.2" | jq '.' > $OUTPUTPATH/createServiceOutput.json); do
    printf "waiting to create service connection"
    sleep 5
done
SERVICECONNECTIONID=$(jq -r '.id' < $OUTPUTPATH/createServiceOutput.json)
sleep 30

#create service connector for git integration
echo "creating service connection for git integration"
[ -e $DATAPATH/createGitServiceConnectionData.json ] && rm $DATAPATH/createGitServiceConnectionData.json
[ -e $OUTPUTPATH/createGitServiceOutput.json ] && rm $OUTPUTPATH/createGitServiceOutput.json
cp $TEMPLATEPATH/createGitServiceConnectionDataTemplate.json $DATAPATH/createGitServiceConnectionData.json
GITSERVICECONNECTIONIDGEN=$(uuidgen)
GITSERVICECONNECTIONNAME="Github service connection-"$HASH
sed -i'' -e "s|\${gitServiceConnectionId}|$GITSERVICECONNECTIONIDGEN|; s|\${gitPAT}|$GITPAT|; s|\${gitServiceConnectionName}|$GITSERVICECONNECTIONNAME|" $DATAPATH/createGitServiceConnectionData.json
until $(curl -u $USERCRED --header "Content-Type: application/json" --request POST --data "@$DATAPATH/createGitServiceConnectionData.json" "https://dev.azure.com/$ORGNAME/$PROJECTNAME/_apis/serviceendpoint/endpoints?api-version=5.0-preview.2" | jq '.' > $OUTPUTPATH/createGitServiceOutput.json); do
    printf "waiting to create service connection"
    sleep 5
done
GITSERVICECONNECTIONID=$(jq -r '.id' < $OUTPUTPATH/createGitServiceOutput.json)
sleep 30

#create build pipeline
echo "creating build pipeline"
[ -e $DATAPATH/createBuildPipelineData.json ] && rm $DATAPATH/createBuildPipelineData.json
[ -e $OUTPUTPATH/createBuildOutput.json ] && rm $OUTPUTPATH/createBuildOutput.json
cp $TEMPLATEPATH/createBuildPipelineTemplate.json $DATAPATH/createBuildPipelineData.json
REGISTRYSKU="basic"
IMAGENAME="azureRig"
LOWERRESOURCEGROUPNAME=$(echo "$RESOURCEGROUPNAME" | awk '{print tolower($0)}')
REGISTRYNAME=$LOWERRESOURCEGROUPNAME"acr"
PIPELINENAME="API Pipeline-"$HASH
sed -i'' -e " s|\${serviceConnectionId}|$SERVICECONNECTIONID|; s|\${groupName}|$RESOURCEGROUPNAME|; s|\${location}|$LOCATION|; s|\${registryName}|$REGISTRYNAME|; s|\${registryAddress}|$COMMON_CONTAINERREGISTRY_URL|; s|\${registrySku}|$REGISTRYSKU|; s|\${imageName}|$IMAGENAME|; s|\${subscriptionId}|$SUBSCRIPTIONID|; s|\${resourceGroupId}|$RESOURCEGROUPID|; s|\${gitOrg}|$GITORG|; s|\${gitRepo}|$GITREPO|; s|\${gitServiceConnectionId}|$GITSERVICECONNECTIONID|; s|\${orgName}|$ORGNAME|; s|\${pipelineName}|$PIPELINENAME|; s|\${projectId}|$PROJECTID|; s|\${projectName}|$PROJECTNAME|; s|STORAGE_ACCOUNT_KEY|$COMMON_STORAGEACCOUNT_KEY|; s|STORAGE_ACCOUNT_NAME|$COMMON_STORAGEACCOUNT_NAME|; s|STORAGE_ACCOUNT_URL|$COMMON_STORAGEACCOUNT_CONTAINER_URL|" $DATAPATH/createBuildPipelineData.json
until $(curl -u $USERCRED --header "Content-Type: application/json" --request POST --data "@$DATAPATH/createBuildPipelineData.json" "https://dev.azure.com/$ORGNAME/$PROJECTNAME/_apis/build/definitions?api-version=5.0" | jq '.' > $OUTPUTPATH/createBuildOutput.json); do
    printf "wating to create pipeline"
    sleep 5
done
PIPELINEID=$(jq -r '.id' < $OUTPUTPATH/createBuildOutput.json)
sleep 30

#queue build pipeline
echo "queueing build"
[ -e $DATAPATH/queueBuildData.json ] && rm $DATAPATH/queueBuildData.json
[ -e $OUTPUTPATH/queueBuildOutput.json ] && rm $OUTPUTPATH/queueBuildOutput.json
cp $TEMPLATEPATH/queueBuildDataTemplate.json $DATAPATH/queueBuildData.json
sed -i'' -e " s|\${pipelineId}|$PIPELINEID|; s|\${pipelineName}|$PIPELINENAME|; s|\${projectId}|$PROJECTID|; s|\${projectName}|$PROJECTNAME|; s|\${orgName}|$ORGNAME|" $DATAPATH/queueBuildData.json
until $(curl -u $USERCRED --header "Content-Type: application/json" --request POST --data "@$DATAPATH/queueBuildData.json" "https://dev.azure.com/$ORGNAME/$PROJECTNAME/_apis/build/builds?api-version=5.0" | jq '.' > $OUTPUTPATH/queueBuildOutput.json); do
    printf "waiting to queue build"
    sleep 5
done