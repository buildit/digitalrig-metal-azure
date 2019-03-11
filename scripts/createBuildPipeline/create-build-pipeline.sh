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

#create build pipelines
echo "creating build pipeline for dev"
DATAFILE=createDevBuildPipelineData.json
OUTPUTFILE=createDevBuildOutput.json
[ -e $DATAPATH/$DATAFILE ] && rm $DATAPATH/$DATAFILE
[ -e $OUTPUTPATH/$OUTPUTFILE ] && rm $OUTPUTPATH/$OUTPUTFILE
cp $TEMPLATEPATH/createBuildPipelineTemplate.json $DATAPATH/$DATAFILE
REGISTRYSKU="basic"
BASEIMAGENAME="azureRig"
LOWERRESOURCEGROUPNAME=$(echo "$RESOURCEGROUPNAME" | awk '{print tolower($0)}')
REGISTRYNAME=$LOWERRESOURCEGROUPNAME"acr"
REGISTRYADDRESS=$REGISTRYNAME".azurecr.io"

STAGENAME="DEV"
PIPELINENAME="$STAGENAME Pipeline CI-"$HASH
IMAGENAME=$BASEIMAGENAME$STAGENAME
IMAGENAME=$(echo "$IMAGENAME" | awk '{print tolower($0)}')
BRANCH="feature/ARI-43-Create-Release-Pipeline"
sed -i'' -e " s|\${serviceConnectionId}|$SERVICECONNECTIONID|; s|\${groupName}|$RESOURCEGROUPNAME|; s|\${location}|$LOCATION|; s|\${registryName}|$REGISTRYNAME|; s|\${registryAddress}|$REGISTRYADDRESS|; s|\${registrySku}|$REGISTRYSKU|; s|\${imageName}|$IMAGENAME|; s|\${subscriptionId}|$SUBSCRIPTIONID|; s|\${resourceGroupId}|$RESOURCEGROUPID|; s|\${gitOrg}|$GITORG|; s|\${gitRepo}|$GITREPO|; s|\${gitServiceConnectionId}|$GITSERVICECONNECTIONID|; s|\${orgName}|$ORGNAME|; s|\${pipelineName}|$PIPELINENAME|; s|\${projectId}|$PROJECTID|; s|\${projectName}|$PROJECTNAME|; s|\${branch}|$BRANCH|" $DATAPATH/$DATAFILE
until $(curl -u $USERCRED --header "Content-Type: application/json" --request POST --data "@$DATAPATH/$DATAFILE" "https://dev.azure.com/$ORGNAME/$PROJECTNAME/_apis/build/definitions?api-version=5.0" | jq '.' > $OUTPUTPATH/$OUTPUTFILE); do
    printf "wating to create pipeline"
    sleep 5
done
DEVPIPELINEID=$(jq -r '.id' < $OUTPUTPATH/$OUTPUTFILE)
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

echo "creating production pipeline"
DATAFILE=createProdBuildPipelineData.json
OUTPUTFILE=createProdBuildOutput.json
[ -e $DATAPATH/$DATAFILE ] && rm $DATAPATH/$DATAFILE
[ -e $OUTPUTPATH/$OUTPUTFILE ] && rm $OUTPUTPATH/$OUTPUTFILE
cp $TEMPLATEPATH/createBuildPipelineTemplate.json $DATAPATH/$DATAFILE

STAGENAME="PROD"
PIPELINENAME="$STAGENAME Pipeline CI-"$HASH
IMAGENAME=$BASEIMAGENAME$STAGENAME
IMAGENAME=$(echo "$IMAGENAME" | awk '{print tolower($0)}')
BRANCH="master"
sed -i'' -e " s|\${serviceConnectionId}|$SERVICECONNECTIONID|; s|\${groupName}|$RESOURCEGROUPNAME|; s|\${location}|$LOCATION|; s|\${registryName}|$REGISTRYNAME|; s|\${registryAddress}|$REGISTRYADDRESS|; s|\${registrySku}|$REGISTRYSKU|; s|\${imageName}|$IMAGENAME|; s|\${subscriptionId}|$SUBSCRIPTIONID|; s|\${resourceGroupId}|$RESOURCEGROUPID|; s|\${gitOrg}|$GITORG|; s|\${gitRepo}|$GITREPO|; s|\${gitServiceConnectionId}|$GITSERVICECONNECTIONID|; s|\${orgName}|$ORGNAME|; s|\${pipelineName}|$PIPELINENAME|; s|\${projectId}|$PROJECTID|; s|\${projectName}|$PROJECTNAME|; s|\${branch}|$BRANCH|" $DATAPATH/$DATAFILE
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
