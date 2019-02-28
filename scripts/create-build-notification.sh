#!/bin/bash


# Set the default values for the parameter variables.
DEFAULT_USERNAME="nicholas.galazzo"
DEFAULT_TOKEN="***REMOVED***"
DEFAULT_PROJECT_URL="https://dev.azure.com/rigtest"
DEFAULT_PROJECT_ID="e2eb2c17-9bef-4d0c-93a0-650bd0b2e28d"
DEFAULT_TFS_SUBSCRIPTION_ID="9b03f034-368f-4155-ab95-cf3f43d9f18d"
DEFAULT_SLACK_HOOK_URL="https://hooks.slack.com/services/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"
DEFAULT_HOOK_SUBSCRIPTION_ID="61358a3e-7ef0-4019-943f-9edcc18efe48"


# Read the parameter values from the command line.
echo
echo "Please fill in the config settings to store in your build-notification.json"
echo "Defaults are shown in parenthesis.  <Enter> to accept."
echo

read -p "User Name (\"$DEFAULT_USERNAME\"): " USERNAME
read -p "Personal Access Token (\"$DEFAULT_TOKEN\"): " TOKEN
read -p "Project URL (\"$DEFAULT_PROJECT_URL\"): " PROJECT_URL
read -p "Project Id (\"$DEFAULT_PROJECT_ID\"): " PROJECT_ID
read -p "TFS Subscription Id (\"$DEFAULT_TFS_SUBSCRIPTION_ID\"): " TFS_SUBSCRIPTION_ID
read -p "Slack Hook URL (\"$DEFAULT_SLACK_HOOK_URL\"): " SLACK_HOOK_URL
read -p "Hook Subscription Id (\"$DEFAULT_HOOK_SUBSCRIPTION_ID\"): " HOOK_SUBSCRIPTION_ID
echo


# Assign the default values if the user didn't enter any value.
USERNAME="${USERNAME:-$DEFAULT_USERNAME}"
TOKEN="${TOKEN:-$DEFAULT_TOKEN}"
PROJECT_URL="${PROJECT_URL:-$DEFAULT_PROJECT_URL}"
PROJECT_ID="${PROJECT_ID:-$DEFAULT_PROJECT_ID}"
TFS_SUBSCRIPTION_ID="${TFS_SUBSCRIPTION_ID:-$DEFAULT_TFS_SUBSCRIPTION_ID}"
SLACK_HOOK_URL="${SLACK_HOOK_URL:-$DEFAULT_SLACK_HOOK_URL}"
HOOK_SUBSCRIPTION_ID="${HOOK_SUBSCRIPTION_ID:-$DEFAULT_HOOK_SUBSCRIPTION_ID}"


# Build the build-notification.json file using the above parameters.
PARAM_FILE="output/build-notification.json"
cp templates/build-notification.json $PARAM_FILE

sed -i '' "s~PROJECT_URL~${PROJECT_URL}~g" $PARAM_FILE
sed -i '' "s/PROJECT_ID/${PROJECT_ID}/g" $PARAM_FILE
sed -i '' "s/TFS_SUBSCRIPTION_ID/${TFS_SUBSCRIPTION_ID}/g" $PARAM_FILE
sed -i '' "s~SLACK_HOOK_URL~${SLACK_HOOK_URL}~g" $PARAM_FILE
sed -i '' "s/HOOK_SUBSCRIPTION_ID/${HOOK_SUBSCRIPTION_ID}/g" $PARAM_FILE


# Sends the request to the Azure API endpoint.
curl -u "${USERNAME}:${TOKEN}" \
    "${PROJECT_URL}/_apis/hooks/subscriptions?api-version=5.0" \
    -H "Accept: application/json" \
    -H "Content-type: application/json" \
    -X POST \
    -d "@${PARAM_FILE}"


# Display an output message and end the script.
echo
echo
echo "Build Notification created!"
echo