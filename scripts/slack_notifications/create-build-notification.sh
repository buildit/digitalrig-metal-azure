#!/bin/bash

# Get parameters from parameter.json file.
USERNAME=$(jq -r '.parameters.sites_RigContainerApp_name.value' < ./templates/parameters.json)
PAT=$(jq -r '.parameters.devops_pat.value' < ./templates/parameters.json)
ORGNAME=$(js -r '.parameters.devops_org_name.value' < ./templates/parameters.json) 
PROJECT_URL = "https://dev.azure.com/${ORGNAME}"
PROJECT_ID= $(jq -r '.parameters.devops_proj_id.value' < ./templates/parameter.json)
SUBSCRIPTION_ID=$(jq -r '.id' < ./outputs/loginOutput.json)
SLACK_HOOK_URL="https://hooks.slack.com/services/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"

# Build the build-notification.json file using the above parameters.
TEMPLATE_FILE="output/build-notification.json"
cp templates/build-notification.json $TEMPLATE_FILE

sed -i '' "s/PROJECT_ID/${PROJECT_ID}/g" $TEMPLATE_FILE
sed -i '' "s/SUBSCRIPTION_ID/${SUBSCRIPTION_ID}/g" $TEMPLATE_FILE
sed -i '' "s~SLACK_HOOK_URL~${SLACK_HOOK_URL}~g" $TEMPLATE_FILE

# Sends the request to the Azure API endpoint.
curl -u "${USERNAME}:${PAT}" \
    "${PROJECT_URL}/_apis/hooks/subscriptions?api-version=5.0" \
    -H "Accept: application/json" \
    -H "Content-type: application/json" \
    -X POST \
    -d "@${TEMPLATE_FILE}"


# Display an output message and end the script.
echo
echo
echo "Build Notification created!"
echo