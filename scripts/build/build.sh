#! /bin/bash

. ../test.config
# variables defined in config
# RESOURCEGROUPNAME
# LOCATION
# USERCRED
# ORGNAME
# PROJECTNAME
# PROJECTID
# GITPAT
# REGISTRYSKU
# IMAGENAME
# GITORG
# GITREPO

#set up resources used in build
[ -e ./outputs/loginOutput.json ] && rm ./outputs/loginOutput.json
until $(az login  > ./outputs/loginOutput.json ); do
    printf 'waiting to log in' 
    sleep 5
done
sed -i '1,2d;$d' ./outputs/loginOutput.json
echo "logged in successful"
cat ./outputs/loginOutput.json
export SUBSCRIPTIONID=$(jq -r '.id' < ./outputs/loginOutput.json)
export TENNANTID=$(jq -r '.tenantId' < ./outputs/loginOutput.json)

#create resource group
[ -e ./outputs/groupCreateOutput.json ] && rm ./outputs/groupCreateOutput.json
until $(az group create --name $RESOURCEGROUPNAME --location "$LOCATION" > ./outputs/groupCreateOutput.json); do
    printf 'waiting to create resource group'
    sleep 5
done
echo "created resource group successful"
cat ./outputs/groupCreateOutput.json
export RESOURCEGROUPID=$(jq -r '.id' < ./outputs/groupCreateOutput.json)
sleep 120

#import values into createServiceConnectionData.json
echo "creating service connection for build tasks"
[ -e ./data/createServiceConnectionData.json ] && rm ./data/createServiceConnectionData.json
[ -e ./outputs/createServiceOutput.json ] && rm ./outputs/createServiceOutput.json
cp ./templates/createServiceConnectionDataTemplate.json ./data/createServiceConnectionData.json
SERVICECONNECTIONIDGEN=$(uuidgen)
SERVICECONNECTIONNAME="Azure Service Connection"
sed -i "s|\${serviceConnectionId}|$SERVICECONNECTIONIDGEN|; s|\${tennantId}|$TENNANTID|; s|\${resourceGroupId}|$RESOURCEGROUPID|; s|\${subscriptionId}|$SUBSCRIPTIONID|; s|\${connectionName}|$SERVICECONNECTIONNAME|" ./data/createServiceConnectionData.json
#user credentials should be form username:PAT and defined in config
until $(curl -u $USERCRED --header "Content-Type: application/json" --request POST --data "@./data/createServiceConnectionData.json" "https://dev.azure.com/$ORGNAME/$PROJECTNAME/_apis/serviceendpoint/endpoints?api-version=5.0-preview.2" | jq '.' > ./outputs/createServiceOutput.json); do
    printf "waiting to create service connection"
    sleep 5
done
export SERVICECONNECTIONID=$(jq -r '.id' < ./outputs/createServiceOutput.json)
sleep 120

#create service connector for git integration
echo "creating service connection for git integration"
[ -e ./data/createGitServiceConnectionData.json ] && rm ./data/createGitServiceConnectionData.json
[ -e ./outputs/createGitServiceOutput.json ] && rm ./outputs/createGitServiceOutput.json
cp ./templates/createGitServiceConnectionDataTemplate.json ./data/createGitServiceConnectionData.json
GITSERVICECONNECTIONIDGEN=$(uuidgen)
GITSERVICECONNECTIONNAME="Github service connection"
sed -i "s|\${gitServiceConnectionId}|$GITSERVICECONNECTIONIDGEN|; s|\${gitPAT}|$GITPAT|; s|\${gitServiceConnectionName}|$GITSERVICECONNECTIONNAME|" ./data/createGitServiceConnectionData.json
until $(curl -u $USERCRED --header "Content-Type: application/json" --request POST --data "@./data/createGitServiceConnectionData.json" "https://dev.azure.com/$ORGNAME/$PROJECTNAME/_apis/serviceendpoint/endpoints?api-version=5.0-preview.2" | jq '.' > ./outputs/createGitServiceOutput.json); do
    printf "waiting to create service connection"
    sleep 5
done
export GITSERVICECONNECTIONID=$(jq -r '.id' < ./outputs/createGitServiceOutput.json)
sleep 120

#create build pipeline
echo "creating build pipeline"
[ -e ./data/createBuildPipelineData.json ] && rm ./data/createBuildPipelineData.json
[ -e ./outputs/createBuildOutput.json ] && rm ./outputs/createBuildOutput.json.json
cp ./templates/createBuildPipelineTemplate.json ./data/createBuildPipelineData.json
LOWERRESOURCEGROUPNAME=$(echo "$RESOURCEGROUPNAME" | awk '{print tolower($0)}')
REGISTRYNAME=$LOWERRESOURCEGROUPNAME"acr"
REGISTRYADDRESS=$REGISTRYNAME".azurecr.io"
PIPELINENAME="API Created Buildpipeline"
sed -i " s|\${serviceConnectionId}|$SERVICECONNECTIONID|; s|\${groupName}|$RESOURCEGROUPNAME|; s|\${location}|$LOCATION|; s|\${registryName}|$REGISTRYNAME|; s|\${registryAddress}|$REGISTRYADDRESS|; s|\${registrySku}|$REGISTRYSKU|; s|\${imageName}|$IMAGENAME|; s|\${subscriptionId}|$SUBSCRIPTIONID|; s|\${resourceGroupId}|$RESOURCEGROUPID|; s|\${gitOrg}|$GITORG|; s|\${gitRepo}|$GITREPO|; s|\${gitServiceConnectionId}|$GITSERVICECONNECTIONID|; s|\${orgName}|$ORGNAME|; s|\${pipelineName}|$PIPELINENAME|; s|\${projectId}|$PROJECTID|; s|\${projectName}|$PROJECTNAME|" ./data/createBuildPipelineData.json
until $(curl -u $USERCRED --header "Content-Type: application/json" --request POST --data "@./data/createBuildPipelineData.json" "https://dev.azure.com/$ORGNAME/$PROJECTNAME/_apis/build/definitions?api-version=5.0" | jq '.' > ./outputs/createBuildOutput.json); do
    printf "wating to create pipeline"
    sleep 5
done
