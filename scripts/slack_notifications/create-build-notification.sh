#!/bin/bash

#
DATAPATH=./scripts/slack_notifications/data/
OUTPUTPATH=./scripts/slack_notifications/outputs/
TEMPLATEPATH=./scripts/slack_notifications/templates/

mkdir -p $DATAPATH
mkdir -p $OUTPUTPATH
mkdir -p $TEMPLATEPATH

# Get parameters from parameter.json file.
USERNAME=$(jq -r '.parameters.devops_user.value' < ./output/parameters.json)
PAT=$(jq -r '.parameters.devops_PAT.value' < ./output/parameters.json)
ORGNAME=$(jq -r '.parameters.devops_org_name.value' < ./output/parameters.json) 
PROJECT_URL="https://dev.azure.com/${ORGNAME}"
PROJECT_ID=$(jq -r '.parameters.devops_proj_id.value' < ./output/parameters.json)
SUBSCRIPTION_ID=$(jq -r '.parameters.subscription_id.value' < ./output/parameters.json)
SLACK_HOOK_URL="https://hooks.slack.com/services/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"

# Build the build-notification.json file using the above parameters.
TEMPLATE_FILE="${TEMPLATEPATH}build-notification.json"
DATA_FILE="${DATAPATH}buildNotificationData.json"
OUTPUT_FILE="${OUTPUTPATH}createBuildNotificationOutput.json"
cp $TEMPLATE_FILE $DATA_FILE

sed -i '' -e "s/PROJECT_ID/${PROJECT_ID}/g" $DATA_FILE
sed -i '' -e "s/SUBSCRIPTION_ID/${SUBSCRIPTION_ID}/g" $DATA_FILE
sed -i '' -e "s~SLACK_HOOK_URL~${SLACK_HOOK_URL}~g" $DATA_FILE

echo "${USERNAME}:${PAT}"
echo ${PROJECT_URL}/_apis/hooks/subscriptions?api-version=5.0

# Sends the request to the Azure API endpoint.
curl -u "${USERNAME}:${PAT}" \
    "${PROJECT_URL}/_apis/hooks/subscriptions?api-version=5.0" \
    -H "Accept: application/json" \
    -H "Content-type: application/json" \
    -X POST \
    -d "@$DATA_FILE" \
  > $OUTPUT_FILE


# Display an output message and end the script.
echo
echo
echo "Build Notification created!"
echo