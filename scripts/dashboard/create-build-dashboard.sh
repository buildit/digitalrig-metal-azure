#!/bin/bash

#
DATAPATH=./scripts/dashboard/data/
OUTPUTPATH=./scripts/dashboard/outputs/
TEMPLATEPATH=./scripts/dashboard/templates/

mkdir -p $DATAPATH
mkdir -p $OUTPUTPATH
mkdir -p $TEMPLATEPATH

# Get parameters from parameter.json file.
USERNAME=$(jq -r '.parameters.devops_user.value' < ./output/parameters.json)
PAT=$(jq -r '.parameters.devops_PAT.value' < ./output/parameters.json)
PROJECT_NAME=$(jq -r '.parameters.devops_proj_name.value' < ./output/parameters.json)
ORGNAME=$(jq -r '.parameters.devops_org_name.value' < ./output/parameters.json) 
PROJECT_TEAM=$(jq -r '.parameters.devops_proj_team.value' < ./output/parameters.json)
URL="https://dev.azure.com/${ORGNAME}/${PROJECT_NAME}/${PROJECT_TEAM}/_apis/dashboard/dashboards?api-version=5.0-preview.2"

# Build the build-notification.json file using the above parameters.
TEMPLATE_FILE="${TEMPLATEPATH}build-dashboard.json"
DATA_FILE="${DATAPATH}buildDashboardData.json"
OUTPUT_FILE="${OUTPUTPATH}createDashboardOutput.json"
cp $TEMPLATE_FILE $DATA_FILE

sed -i '' -e "s/DASHBOARD_NAME/${PROJECT_NAME}Dashboard/g" $DATA_FILE


echo $URL
echo ${USERNAME}:${PAT}
echo $DATA_FILE

curl -u "${USERNAME}:${PAT}" \
"${URL}" \
-H "Accept: application/json" \
-H "Content-type: application/json" \
-X POST \
-d "@$DATA_FILE" \
 > $OUTPUT_FILE

# Display an output message and end the script.
echo
echo
echo "Project Dashboard Created!"
echo