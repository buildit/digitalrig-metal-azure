#!/bin/bash

# Set the default values for the parameter variables.
DEFAULT_CONTAINER_APP_NAME="RigContainerApp"
DEFAULT_LOCATION="centralus"
DEFAULT_RESOURCEGROUP_NAME="chihhoSandbox"
ORGNAME="ChihhoBuilditAzureSandbox"
PROJECTNAME="AzureRig"
PROJECTID="ce12ac0f-b76c-4884-8d28-d5df454322ff"
GITORG="buildit"
GITREPO="slackbot"


# Read the parameter values from the command line.
echo
echo "Please fill in the config settings to store in your parameters.json"
echo "Defaults are shown in parenthesis.  <Enter> to accept."
echo

read -p "Location (\"$DEFAULT_LOCATION\"): " LOCATION
LOCATION="${LOCATION:-$DEFAULT_LOCATION}"
#if param file exists use existing valuesPROJECTNAME
PARAM_FILE="output/parameters.json"
if [ -e $PARAM_FILE ]
then
    DEVOPSUSERNAME=$(jq -r '.parameters.devops_user.value' < ./output/parameters.json)
    DEVOPSPAT=$(jq -r '.parameters.devops_PAT.value' < ./output/parameters.json)
    ORGNAME=$(jq -r '.parameters.devops_org_name.value' < ./output/parameters.json)
    PROJECTNAME=$(jq -r '.parameters.devops_proj_name.value' < ./output/parameters.json)
    PROJECTID=$(jq -r '.parameters.devops_proj_id.value' < ./output/parameters.json)
else
    while [[ -z "$DEVOPSUSERNAME" ]]
    do
        read -p "Devops Username (normally email with Azure subscription): " DEVOPSUSERNAME
    done

    while [[ -z "$DEVOPSPAT" ]]
    do
        read -p "Devops Personal Access Token (check readme for instructions to get): " DEVOPSPAT
    done
    cp templates/parameters.json $PARAM_FILE
fi


while [[ -z "$GITPAT" ]]
do
    read -p "Github Personal Access Token (check readme for instructions to get): " GITPAT
done

read -p "Base Resource Name must be less than 18 characters(\"$DEFAULT_RESOURCEGROUP_NAME\"): " RESOURCEGROUP_NAME

RESOURCEGROUP_NAME="${RESOURCEGROUP_NAME:-$DEFAULT_RESOURCEGROUP_NAME}"

# Assign the default values if the user didn't enter any value.
CONTAINER_APP_NAME="${CONTAINER_APP_NAME:-$DEFAULT_CONTAINER_APP_NAME}"

# Build the parameters.json file using the above parameters.
#FIND A COMMAND THAT WORKS FOR BOTH LINUX AND MAC 
sed -i'' -e "s/CONTAINER_APP_NAME/${CONTAINER_APP_NAME}/g" $PARAM_FILE
sed -i'' -e "s/PROJECTID/${PROJECTID}/g" $PARAM_FILE
sed -i'' -e "s/LOCATION/${LOCATION}/g" $PARAM_FILE
sed -i'' -e "s/RESOURCEGROUP_NAME/${RESOURCEGROUP_NAME}/g" $PARAM_FILE
sed -i'' -e "s/ORGNAME/${ORGNAME}/g" $PARAM_FILE
sed -i'' -e "s/PROJECTNAME/${PROJECTNAME}/g" $PARAM_FILE
sed -i'' -e "s/DEVOPSPAT/${DEVOPSPAT}/g" $PARAM_FILE
sed -i'' -e "s/DEVOPSUSERNAME/${DEVOPSUSERNAME}/g" $PARAM_FILE
sed -i'' -e "s/GITORG/${GITORG}/g" $PARAM_FILE
sed -i'' -e "s/GITREPO/${GITREPO}/g" $PARAM_FILE
sed -i'' -e "s/GITPAT/${GITPAT}/g" $PARAM_FILE


# Display an output message and end the script.
echo "Saved parameters.json!"
echo