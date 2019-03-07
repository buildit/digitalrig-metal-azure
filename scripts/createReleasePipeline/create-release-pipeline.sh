#! /bin/bash

#hash to identifty build pipeline resources
VERSIONHASH=$(jq -r '.parameters.versionHash.value' < ./output/parameters.json)
# HASH=jSvt8G #$( cat /dev/urandom | env LC_CTYPE=C tr -dc a-zA-Z0-9 | head -c 6 ; echo '')
DATAPATH=./scripts/createReleasePipeline/data
OUTPUTPATH=./scripts/createReleasePipeline/outputs
TEMPLATEPATH=./scripts/createReleasePipeline/templates
mkdir -p $DATAPATH
mkdir -p $OUTPUTPATH
mkdir -p $TEMPLATEPATH

# variables defined in parameters
RESOURCEGROUPNAME=$(jq -r '.parameters.resourceGroupName.value' < ./output/parameters.json)
LOCATION=$(jq -r '.parameters.location.value' < ./output/parameters.json)
DEVOPSUSER=$(jq -r '.parameters.devops_user.value' < ./output/parameters.json)
DEVOPSPAT=$(jq -r '.parameters.devops_PAT.value' < ./output/parameters.json)
DEVOPSOWNER=$(jq -r '.parameters.devops_owner.value' < ./output/parameters.json)
USERCRED=$DEVOPSUSER:$DEVOPSPAT
ORGNAME=$(jq -r '.parameters.devops_org_name.value' < ./output/parameters.json)
PROJECTNAME=$(jq -r '.parameters.devops_proj_name.value' < ./output/parameters.json)
SERVICECONNECTIONID=$(jq -r '.parameters.serviceConnectionId.value' < ./output/parameters.json)
APPNAME=$RESOURCEGROUPNAME"App" #$(jq -r '.parameters.sites_RigContainerApp_name.value' < ./output/parameters.json)
PROJECTID=$(jq -r '.parameters.devops_proj_id.value' < ./output/parameters.json)
PIPELINEID=$(jq -r '.parameters.pipelineId.value' < ./output/parameters.json)

#get properties from DEVOPSOWNER (DO)
DO_DISPLAYNAME=$(jq -r '.parameters.DO_Displayname.value' < ./output/parameters.json)
DO_URL=$(jq -r '.parameters.DO_Url.value' < ./output/parameters.json)
DO_HREF=$(jq -r '.parameters.DO_Href.value' < ./output/parameters.json)
DO_ID=$(jq -r '.parameters.DO_Id.value' < ./output/parameters.json)
DO_UNIQUENAME=$(jq -r '.parameters.DO_Uniquename.value' < ./output/parameters.json)
DO_IMAGEURL=$(jq -r '.parameters.DO_Imageurl.value' < ./output/parameters.json)
DO_DESCRIPTOR=$(jq -r '.parameters.DO_Descriptor.value' < ./output/parameters.json)
echo "$DO_DISPLAYNAME"
#create release pipeline
echo "creating release pipeline"
[ -e $DATAPATH/createReleasePipelineData.json ] && rm $DATAPATH/createReleasePipelineData.json
[ -e $OUTPUTPATH/createReleaseOutput.json ] && rm $OUTPUTPATH/createReleaseOutput.json
cp $TEMPLATEPATH/createReleasePipelineTemplate.json $DATAPATH/createReleasePipelineData.json
REGISTRYSKU="basic"
IMAGENAME="azureRig"
LOWERRESOURCEGROUPNAME=$(echo "$RESOURCEGROUPNAME" | awk '{print tolower($0)}')
REGISTRYNAME=$LOWERRESOURCEGROUPNAME"acr"
REGISTRYADDRESS=$REGISTRYNAME".azurecr.io"
PIPELINENAME="API Pipeline CD-"$VERSIONHASH
sed -i'' -e " s|\${serviceConnectionId}|$SERVICECONNECTIONID|g; s|\${resourceGroupName}|$RESOURCEGROUPNAME|g; s|\${location}|$LOCATION|g; s|\${registryName}|$REGISTRYNAME|g; s|\${appName}|$APPNAME|g; s|\${registrySku}|$REGISTRYSKU|g; s|\${imageName}|$IMAGENAME|g; s|\${orgName}|$ORGNAME|g; s|\${pipelineName}|$PIPELINENAME|g; s|\${pipelineId}|$PIPELINEID|g" $DATAPATH/createReleasePipelineData.json
sed -i'' -e " s|\${DO_DisplayName}|$DO_DISPLAYNAME|g; s|\${DO_ID}|$DO_ID|g; s|\${DO_UniqueName}|$DO_UNIQUENAME|g; s|\${DO_URL}|$DO_URL|g; s|\${DO_HREF}|$DO_HREF|g; s|\${DO_UNIQUENAME}|$DO_UNIQUENAME|g; s|\${DO_ImageURL}|$DO_IMAGEURL|g; s|\${DO_Descriptor}|$DO_DESCRIPTOR|g; s|\${versionHash}|$VERSIONHASH|g; s|\${projectId}|$PROJECTID|g" $DATAPATH/createReleasePipelineData.json
until $(curl -u $USERCRED --header "Content-Type: application/json" --request POST --data "@$DATAPATH/createReleasePipelineData.json" "https://vsrm.dev.azure.com/$ORGNAME/$PROJECTNAME/_apis/release/definitions?api-version=5.0" | jq '.' > $OUTPUTPATH/createReleaseOutput.json); do
    printf "wating to create pipeline"
    sleep 5
done
#PIPELINEID=$(jq -r '.id' < $OUTPUTPATH/createReleaseOutput.json)
