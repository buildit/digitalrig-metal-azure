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
BASEAPPNAME=$BASERESOURCEGROUPNAME"App"  #$(jq -r '.parameters.sites_RigContainerApp_name.value' < ./output/parameters.json)
OWNER_ID=$(jq -r '.parameters.ownerId.value' < ./output/parameters.json)

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
PIPELINENAME="$STAGE Pipeline-"$VERSIONHASH
SOURCEPIPELINEID=$(jq -r '.parameters.devPipelineId.value' < ./output/parameters.json)
SOURCEPIPELINENAME=$(jq -r '.parameters.devPipelineName.value' < ./output/parameters.json)
IMAGENAME="azurerig"
IMAGENAME=$(echo "$IMAGENAME" | awk '{print tolower($0)}')
APPNAME=$BASEAPPNAME$STAGE
RESOURCEGROUPNAME=$BASERESOURCEGROUPNAME$STAGE
sed -i'' -e " s|\${serviceConnectionId}|$SERVICECONNECTIONID|g; s|\${resourceGroupName}|$RESOURCEGROUPNAME|g; s|\${location}|$LOCATION|g; s|\${registryName}|$REGISTRYNAME|g; s|\${appName}|$APPNAME|g; s|\${registrySku}|$REGISTRYSKU|g; s|\${imageName}|$IMAGENAME|g; s|\${orgName}|$ORGNAME|g; s|\${pipelineName}|$PIPELINENAME|g; s|\${pipelineId}|$SOURCEPIPELINEID|g" $DATAPATH/$DATAFILE
sed -i'' -e " s|\${OWNER_ID}|$OWNER_ID|g; s|\${sourcePipelineName}|$SOURCEPIPELINENAME|g; s|\${projectId}|$PROJECTID|g" $DATAPATH/$DATAFILE
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
PIPELINENAME="$STAGE Pipeline-"$VERSIONHASH
SOURCEPIPELINEID=$(jq -r '.parameters.prodPipelineId.value' < ./output/parameters.json)
SOURCEPIPELINENAME=$(jq -r '.parameters.prodPipelineName.value' < ./output/parameters.json)
IMAGENAME=$BASEIMAGENAME$STAGE
IMAGENAME=$(echo "$IMAGENAME" | awk '{print tolower($0)}')
APPNAME=$BASEAPPNAME
RESOURCEGROUPNAME=$BASERESOURCEGROUPNAME$STAGE
STAGE1="STAGE"
STAGE2="PROD"
sed -i'' -e " s|\${serviceConnectionId}|$SERVICECONNECTIONID|g; s|\${resourceGroupName}|$RESOURCEGROUPNAME|g; s|\${location}|$LOCATION|g; s|\${registryName}|$REGISTRYNAME|g; s|\${appName}|$APPNAME|g; s|\${registrySku}|$REGISTRYSKU|g; s|\${imageName}|$IMAGENAME|g; s|\${orgName}|$ORGNAME|g; s|\${pipelineName}|$PIPELINENAME|g; s|\${pipelineId}|$SOURCEPIPELINEID|g" $DATAPATH/$DATAFILE
sed -i'' -e " s|\${OWNER_ID}|$OWNER_ID|g; s|\${sourcePipelineName}|$SOURCEPIPELINENAME|g; s|\${projectId}|$PROJECTID|g; s|\${stage1}|$STAGE1|g; s|\${stage2}|$STAGE2|g" $DATAPATH/$DATAFILE
until $(curl -u $USERCRED --header "Content-Type: application/json" --request POST --data "@$DATAPATH/$DATAFILE" "https://vsrm.dev.azure.com/$ORGNAME/$PROJECTNAME/_apis/release/definitions?api-version=5.0" | jq '.' > $OUTPUTPATH/createProdReleaseOutput.json); do
    printf "wating to create pipeline"
    sleep 5
done
