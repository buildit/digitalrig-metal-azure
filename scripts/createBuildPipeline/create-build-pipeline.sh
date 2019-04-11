#! /bin/bash

#hash to identifty build pipeline resources
HASH=$( cat /dev/urandom | env LC_CTYPE=C tr -dc a-zA-Z0-9 | head -c 6 ; echo '')
sed -i'' -e "s/VERSIONHASH/${HASH}/g" ./output/parameters.json
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
GITBRANCH=$1
COMMON_RESOURCEGROUP_ID=$(jq -r '.parameters.commonResourceGroupId.value' < ./output/parameters.json)
COMMON_STORAGEACCOUNT_NAME=$(jq -r '.parameters.commonStorageAccountName.value' < ./output/parameters.json)
COMMON_STORAGEACCOUNT_KEY=$(jq -r '.parameters.commonStorageAccountKey.value' < ./output/parameters.json)
COMMON_CONTAINERREGISTRY_URL=$(jq -r '.parameters.commonContainerRegistryName.value' < ./output/parameters.json)"azurecr.io"

#creates an blob storage container to save the TestResult.xml files
CLEAN_GIT_BRANCH=$(echo "${GITBRANCH//\//-}" | awk '{print tolower($0)}')
COMMON_STORAGEACCOUNT_CONTAINER_NAME="${CLEAN_GIT_BRANCH}-test-results"
az storage container create \
    --name $COMMON_STORAGEACCOUNT_CONTAINER_NAME \
    --account-key $COMMON_STORAGEACCOUNT_KEY \
    --account-name $COMMON_STORAGEACCOUNT_NAME \
    --subscription $SUBSCRIPTIONID
COMMON_STORAGEACCOUNT_CONTAINER_URL="https://${COMMON_STORAGEACCOUNT_NAME}.blob.core.windows.net/${COMMON_STORAGEACCOUNT_CONTAINER_NAME}"

#get the image tag prefix according to the branch name.
# COMMON_CONTAINERREGISTRY_IMAGETAG_PREFIX="unstable-"
# if [ "${GITBRANCH}" == "master" ]; then COMMON_CONTAINERREGISTRY_IMAGETAG_PREFIX=""; fi

#import values into createServiceConnectionData.json
echo "creating service connection for build tasks"
[ -e $DATAPATH/createServiceConnectionData.json ] && rm $DATAPATH/createServiceConnectionData.json
[ -e $OUTPUTPATH/createServiceOutput.json ] && rm $OUTPUTPATH/createServiceOutput.json
cp $TEMPLATEPATH/createServiceConnectionSubscriptionTemplate.json $DATAPATH/createServiceConnectionData.json
SERVICECONNECTIONIDGEN=$(uuidgen)
SERVICECONNECTIONNAME="Azure Service Connection-"$HASH
sed -i'' -e "s|\${serviceConnectionId}|$SERVICECONNECTIONIDGEN|; s|\${tennantId}|$TENNANTID|; s|\${subscriptionId}|$SUBSCRIPTIONID|; s|\${subscriptionName}|$SUBSCRIPTIONNAME|; s|\${connectionName}|$SERVICECONNECTIONNAME|" $DATAPATH/createServiceConnectionData.json
#user credentials should be form username:PAT and defined in config
until $(curl -u $USERCRED --header "Content-Type: application/json" --request POST --data "@$DATAPATH/createServiceConnectionData.json" "https://dev.azure.com/$ORGNAME/$PROJECTNAME/_apis/serviceendpoint/endpoints?api-version=5.0-preview.2" | jq '.' > $OUTPUTPATH/createServiceOutput.json); do
    printf "waiting to create service connection"
    sleep 5
done
SERVICECONNECTIONID=$(jq -r '.id' < $OUTPUTPATH/createServiceOutput.json)
sed -i'' -e "s/\${SERVICECONNECTIONID}/${SERVICECONNECTIONID}/g" ./output/parameters.json
sleep 30
echo ""

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
sed -i'' -e "s/GITHUBSERVICECONNID/${GITSERVICECONNECTIONID}/g" ./output/parameters.json
sed -i'' -e "s/GITHUBSERVICECONNECTIONNAME/${GITSERVICECONNECTIONNAME}/g" ./output/parameters.json
sleep 30
echo ""

#create build pipelines
echo "creating build pipeline for dev"
DATAFILE=createDevBuildPipelineData.json
OUTPUTFILE=createDevBuildOutput.json
[ -e $DATAPATH/$DATAFILE ] && rm $DATAPATH/$DATAFILE
[ -e $OUTPUTPATH/$OUTPUTFILE ] && rm $OUTPUTPATH/$OUTPUTFILE
cp $TEMPLATEPATH/createBuildPipelineTemplate.json $DATAPATH/$DATAFILE
REGISTRYSKU="basic"
LOWERRESOURCEGROUPNAME=$(echo "$RESOURCEGROUPNAME" | awk '{print tolower($0)}')
REGISTRYNAME=$LOWERRESOURCEGROUPNAME"acr"
REGISTRYADDRESS=$REGISTRYNAME".azurecr.io"

STAGENAME="DEV"
PIPELINENAME="$STAGENAME Pipeline CI-"$HASH
IMAGENAME="azurerig"
IMAGETAG="unstable"
BRANCH=$GITBRANCH
sed -i'' -e " s|\${serviceConnectionId}|$SERVICECONNECTIONID|; s|\${groupName}|$RESOURCEGROUPNAME|; s|\${location}|$LOCATION|; s|\${registryName}|$REGISTRYNAME|; s|\${registryAddress}|$REGISTRYADDRESS|; s|\${registryAddress}|$COMMON_CONTAINERREGISTRY_URL|; s|\${registrySku}|$REGISTRYSKU|; s|\${commonContainerRegistryImageTagPrefix}|$COMMON_CONTAINERREGISTRY_IMAGETAG_PREFIX|; s|\${imageName}|$IMAGENAME|; s|\${imageTag}|$IMAGETAG|; s|\${subscriptionId}|$SUBSCRIPTIONID|; s|\${resourceGroupId}|$RESOURCEGROUPID|; s|\${gitOrg}|$GITORG|; s|\${gitRepo}|$GITREPO|; s|\${gitServiceConnectionId}|$GITSERVICECONNECTIONID|; s|\${orgName}|$ORGNAME|; s|\${pipelineName}|$PIPELINENAME|; s|\${projectId}|$PROJECTID|; s|\${projectName}|$PROJECTNAME|; s|\${branch}|$BRANCH|; s|STORAGE_ACCOUNT_KEY|$COMMON_STORAGEACCOUNT_KEY|; s|STORAGE_ACCOUNT_NAME|$COMMON_STORAGEACCOUNT_NAME|; s|STORAGE_ACCOUNT_URL|$COMMON_STORAGEACCOUNT_CONTAINER_URL|; s|STORAGE_ACCOUNT_CONTAINER_NAME|$COMMON_STORAGEACCOUNT_CONTAINER_NAME|" $DATAPATH/$DATAFILE
until $(curl -u $USERCRED --header "Content-Type: application/json" --request POST --data "@$DATAPATH/$DATAFILE" "https://dev.azure.com/$ORGNAME/$PROJECTNAME/_apis/build/definitions?api-version=5.0" | jq '.' > $OUTPUTPATH/$OUTPUTFILE); do
    printf "wating to create pipeline"
    sleep 5
done
DEVPIPELINEID=$(jq -r '.id' < $OUTPUTPATH/$OUTPUTFILE)
AGENTQUEUEID=$(jq -r '.queue.id' < $OUTPUTPATH/$OUTPUTFILE)
sed -i'' -e "s|AGENTQUEUEID|$AGENTQUEUEID|g" ./output/parameters.json
sed -i'' -e "s/DEVPIPELINEID/${DEVPIPELINEID}/g" ./output/parameters.json
sed -i'' -e "s/DEVPIPELINENAME/${PIPELINENAME}/g" ./output/parameters.json
sleep 30
echo ""

#queue dev build pipeline
echo "queueing build"
[ -e $DATAPATH/queueBuildData.json ] && rm $DATAPATH/queueBuildData.json
[ -e $OUTPUTPATH/queueBuildOutput.json ] && rm $OUTPUTPATH/queueBuildOutput.json
cp $TEMPLATEPATH/queueBuildDataTemplate.json $DATAPATH/queueBuildData.json
sed -i'' -e " s|\${pipelineId}|$DEVPIPELINEID|; s|\${pipelineName}|$PIPELINENAME|; s|\${projectId}|$PROJECTID|; s|\${projectName}|$PROJECTNAME|; s|\${orgName}|$ORGNAME|" $DATAPATH/queueBuildData.json
until $(curl -u $USERCRED --header "Content-Type: application/json" --request POST --data "@$DATAPATH/queueBuildData.json" "https://dev.azure.com/$ORGNAME/$PROJECTNAME/_apis/build/builds?api-version=5.0" | jq '.' > $OUTPUTPATH/queueBuildOutput.json); do
    printf "waiting to queue build"
    sleep 5
done
sleep 10
echo ""

#create storage account for stage
COMMON_STORAGEACCOUNT_CONTAINER_NAME="stage-test-results"
az storage container create \
    --name $COMMON_STORAGEACCOUNT_CONTAINER_NAME \
    --account-key $COMMON_STORAGEACCOUNT_KEY \
    --account-name $COMMON_STORAGEACCOUNT_NAME \
    --subscription $SUBSCRIPTIONID

#create storage account for prod
COMMON_STORAGEACCOUNT_CONTAINER_NAME="prod-test-results"
az storage container create \
    --name $COMMON_STORAGEACCOUNT_CONTAINER_NAME \
    --account-key $COMMON_STORAGEACCOUNT_KEY \
    --account-name $COMMON_STORAGEACCOUNT_NAME \
    --subscription $SUBSCRIPTIONID
COMMON_STORAGEACCOUNT_CONTAINER_URL="https://${COMMON_STORAGEACCOUNT_NAME}.blob.core.windows.net/${COMMON_STORAGEACCOUNT_CONTAINER_NAME}"

echo "creating production pipeline"
DATAFILE=createProdBuildPipelineData.json
OUTPUTFILE=createProdBuildOutput.json
[ -e $DATAPATH/$DATAFILE ] && rm $DATAPATH/$DATAFILE
[ -e $OUTPUTPATH/$OUTPUTFILE ] && rm $OUTPUTPATH/$OUTPUTFILE
cp $TEMPLATEPATH/createBuildPipelineTemplate.json $DATAPATH/$DATAFILE

STAGENAME="PROD"
PIPELINENAME="$STAGENAME Pipeline CI-"$HASH
IMAGETAG="stable"
BRANCH="master"
sed -i'' -e " s|\${serviceConnectionId}|$SERVICECONNECTIONID|; s|\${groupName}|$RESOURCEGROUPNAME|; s|\${location}|$LOCATION|; s|\${registryName}|$REGISTRYNAME|; s|\${registryAddress}|$REGISTRYADDRESS|; s|\${registryAddress}|$COMMON_CONTAINERREGISTRY_URL|; s|\${registrySku}|$REGISTRYSKU|; s|\${commonContainerRegistryImageTagPrefix}|$COMMON_CONTAINERREGISTRY_IMAGETAG_PREFIX|; s|\${imageName}|$IMAGENAME|; s|\${imageTag}|$IMAGETAG|; s|\${subscriptionId}|$SUBSCRIPTIONID|; s|\${resourceGroupId}|$RESOURCEGROUPID|; s|\${gitOrg}|$GITORG|; s|\${gitRepo}|$GITREPO|; s|\${gitServiceConnectionId}|$GITSERVICECONNECTIONID|; s|\${orgName}|$ORGNAME|; s|\${pipelineName}|$PIPELINENAME|; s|\${projectId}|$PROJECTID|; s|\${projectName}|$PROJECTNAME|; s|\${branch}|$BRANCH|; s|STORAGE_ACCOUNT_KEY|$COMMON_STORAGEACCOUNT_KEY|; s|STORAGE_ACCOUNT_NAME|$COMMON_STORAGEACCOUNT_NAME|; s|STORAGE_ACCOUNT_URL|$COMMON_STORAGEACCOUNT_CONTAINER_URL|; s|STORAGE_ACCOUNT_CONTAINER_NAME|$COMMON_STORAGEACCOUNT_CONTAINER_NAME|" $DATAPATH/$DATAFILE
until $(curl -u $USERCRED --header "Content-Type: application/json" --request POST --data "@$DATAPATH/$DATAFILE" "https://dev.azure.com/$ORGNAME/$PROJECTNAME/_apis/build/definitions?api-version=5.0" | jq '.' > $OUTPUTPATH/$OUTPUTFILE); do
    printf "wating to create pipeline"
    sleep 5
done
PRODPIPELINEID=$(jq -r '.id' < $OUTPUTPATH/$OUTPUTFILE)
sed -i'' -e "s/PRODPIPELINEID/${PRODPIPELINEID}/g" ./output/parameters.json
sed -i'' -e "s/PRODPIPELINENAME/${PIPELINENAME}/g" ./output/parameters.json
sleep 30
echo ""

#get user info to populate owner fields of owner for pipeline
OWNER_ID=$(jq -r '.requestedFor.id' < $OUTPUTPATH/queueBuildOutput.json)
#populate owner fields in parameters
sed -i'' -e "s|\${OWNER_ID}|$OWNER_ID|g" ./output/parameters.json
