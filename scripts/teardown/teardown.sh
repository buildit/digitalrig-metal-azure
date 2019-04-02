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
echo "deleting common resource group"
az group delete --yes -n $BASERESOURCEGROUPNAME
echo "deleting dev resource group"
az group delete --yes -n $BASERESOURCEGROUPNAME"DEV"
echo "deleting stage resource group"
az group delete --yes -n $BASERESOURCEGROUPNAME"PRODSTAGE"
echo "deleting prod resource group"
az group delete --yes -n $BASERESOURCEGROUPNAME"PRODPROD"

#delete old param file
PARAM_FILE="output/parameters.json"
rm $PARAM_FILE