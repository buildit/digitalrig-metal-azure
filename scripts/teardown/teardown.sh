#!/bin/bash

BASERESOURCEGROUPNAME=$(jq -r '.parameters.resourceGroupName.value' < ./output/parameters.json)
DEVOPSUSER=$(jq -r '.parameters.devops_user.value' < ./output/parameters.json)
DEVOPSPAT=$(jq -r '.parameters.devops_PAT.value' < ./output/parameters.json)
ORGNAME=$(jq -r '.parameters.devops_org_name.value' < ./output/parameters.json)
PROJECTID=$(jq -r '.parameters.devops_proj_id.value' < ./output/parameters.json)
USERCRED=$DEVOPSUSER:$DEVOPSPAT

#delete project
echo "https://dev.azure.com/$ORGNAME/_apis/projects/$PROJECTID?api-version=5.0"
curl -u $USERCRED \
--request DELETE \
"https://dev.azure.com/$ORGNAME/_apis/projects/$PROJECTID?api-version=5.0"

#delete resource groups

az group delete --yes -n $BASERESOURCEGROUPNAME
az group delete --yes -n $BASERESOURCEGROUPNAME"DEV"
az group delete --yes -n $BASERESOURCEGROUPNAME"STAGE"
az group delete --yes -n $BASERESOURCEGROUPNAME"PROD"

#delete old param file

PARAM_FILE="output/parameters.json"
rm $PARAM_FILE