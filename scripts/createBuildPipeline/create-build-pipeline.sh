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
sed -i'' -e "s|\${serviceConnectionId}|$SERVICECONNECTIONIDGEN|; s|\${tennantId}|$TENNANTID|; s|\${resourceGroupId}|$RESOURCEGROUPID|; s|\${subscriptionId}|$SUBSCRIPTIONID|; s|\${subscriptionName}|$SUBSCRIPTIONNAME|; s|\${connectionName}|$SERVICECONNECTIONNAME|" $DATAPATH/createServiceConnectionData.json
#user credentials should be form username:PAT and defined in config
until $(curl -u $USERCRED --header "Content-Type: application/json" --request POST --data "@$DATAPATH/createServiceConnectionData.json" "https://dev.azure.com/$ORGNAME/$PROJECTNAME/_apis/serviceendpoint/endpoints?api-version=5.0-preview.2" | jq '.' > $OUTPUTPATH/createServiceOutput.json); do
    printf "waiting to create service connection"
    sleep 5
done
SERVICECONNECTIONID=$(jq -r '.id' < $OUTPUTPATH/createServiceOutput.json)
sed -i'' -e "s/SERVICECONNECTIONID/${SERVICECONNECTIONID}/g" ./output/parameters.json
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
sleep 30
echo ""

#create build pipeline
echo "creating build pipeline"
[ -e $DATAPATH/createBuildPipelineData.json ] && rm $DATAPATH/createBuildPipelineData.json
[ -e $OUTPUTPATH/createBuildOutput.json ] && rm $OUTPUTPATH/createBuildOutput.json
cp $TEMPLATEPATH/createBuildPipelineTemplate.json $DATAPATH/createBuildPipelineData.json
REGISTRYSKU="basic"
IMAGENAME="azureRig"
LOWERRESOURCEGROUPNAME=$(echo "$RESOURCEGROUPNAME" | awk '{print tolower($0)}')
REGISTRYNAME=$LOWERRESOURCEGROUPNAME"acr"
REGISTRYADDRESS=$REGISTRYNAME".azurecr.io"
PIPELINENAME="API Pipeline CI-"$HASH
sed -i'' -e " s|\${serviceConnectionId}|$SERVICECONNECTIONID|; s|\${groupName}|$RESOURCEGROUPNAME|; s|\${location}|$LOCATION|; s|\${registryName}|$REGISTRYNAME|; s|\${registryAddress}|$REGISTRYADDRESS|; s|\${registrySku}|$REGISTRYSKU|; s|\${imageName}|$IMAGENAME|; s|\${subscriptionId}|$SUBSCRIPTIONID|; s|\${resourceGroupId}|$RESOURCEGROUPID|; s|\${gitOrg}|$GITORG|; s|\${gitRepo}|$GITREPO|; s|\${gitServiceConnectionId}|$GITSERVICECONNECTIONID|; s|\${orgName}|$ORGNAME|; s|\${pipelineName}|$PIPELINENAME|; s|\${projectId}|$PROJECTID|; s|\${projectName}|$PROJECTNAME|" $DATAPATH/createBuildPipelineData.json
until $(curl -u $USERCRED --header "Content-Type: application/json" --request POST --data "@$DATAPATH/createBuildPipelineData.json" "https://dev.azure.com/$ORGNAME/$PROJECTNAME/_apis/build/definitions?api-version=5.0" | jq '.' > $OUTPUTPATH/createBuildOutput.json); do
    printf "wating to create pipeline"
    sleep 5
done
PIPELINEID=$(jq -r '.id' < $OUTPUTPATH/createBuildOutput.json)
sed -i'' -e "s/PIPELINEID/${PIPELINEID}/g" ./output/parameters.json
sleep 30
echo ""

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
sleep 10
echo ""

#get user info to populate owner fields of owner for pipeline
DO_DISPLAYNAME=$(jq -r '.requestedFor.displayName' < $OUTPUTPATH/queueBuildOutput.json)
DO_URL=$(jq -r '.requestedFor.url' < $OUTPUTPATH/queueBuildOutput.json)
DO_HREF=$(jq -r '.requestedFor._links.avatar.href' < $OUTPUTPATH/queueBuildOutput.json)
DO_ID=$(jq -r '.requestedFor.id' < $OUTPUTPATH/queueBuildOutput.json)
DO_UNIQUENAME=$(jq -r '.requestedFor.uniqueName' < $OUTPUTPATH/queueBuildOutput.json)
DO_IMAGEURL=$(jq -r '.requestedFor.imageUrl' < $OUTPUTPATH/queueBuildOutput.json)
DO_DESCRIPTOR=$(jq -r '.requestedFor.descriptor' < $OUTPUTPATH/queueBuildOutput.json)

#populate owner fields in parameters
sed -i'' -e "s|\${DO_DISPLAYNAME}|$DO_DISPLAYNAME|g" ./output/parameters.json
sed -i'' -e "s|\${DO_URL}|$DO_URL|g" ./output/parameters.json
sed -i'' -e "s|\${DO_HREF}|$DO_HREF|g" ./output/parameters.json
sed -i'' -e "s|\${DO_ID}|$DO_ID|g" ./output/parameters.json
sed -i'' -e "s|\${DO_UNIQUENAME}|$DO_UNIQUENAME|g" ./output/parameters.json
sed -i'' -e "s|\${DO_IMAGEURL}|$DO_IMAGEURL|g" ./output/parameters.json
sed -i'' -e "s|\${DO_DESCRIPTOR}|$DO_DESCRIPTOR|g" ./output/parameters.json
