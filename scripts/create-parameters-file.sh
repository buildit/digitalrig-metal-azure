#!/bin/bash

# Set the default values for the parameter variables.
DEFAULT_CONTAINER_APP_NAME="RigContainerApp"
DEFAULT_CONTAINER_PLAN_NAME="RigContainerPlan"
DEFAULT_CONTAINER_REGISTRY_NAME="RigContainerRegistry"
DEFAULT_WEB_CONFIG_NAME="RigWebAppConfig"
DEFAULT_HOST_NAME_BINDING="rigcontainerapp.azurewebsites.net"
DEFAULT_APP_INSIGHTS_NAME="RigAppInsights"

# DEFAULT_DATABASE_LOCATION_NAME="Central US"
# DEFAULT_DATABASE_SERVER_NAME="databaseservername"
# DEFAULT_DATABASE_DB_NAME="testdatabase"
# DEFAULT_DATABASE_ADMIN_USERNAME="azuresqladmin"
# DEFAULT_DATABASE_ADMIN_PASSWORD="foobar@123!456"

DEFAULT_LOCATION="Central US"
DEFAULT_RESOURCEGROUP_NAME="builditSandbox"
ORGNAME="BuilditAzureSandbox"
PROJECTNAME="BuilditAzureRig"
PROJECTID="7b202733-9515-4424-be96-5fb9e2ccc0f3"
GITORG="buildit"
GITREPO="digitalrig-metal-azure"
DEFAULT_GITBRANCH="master"


# Read the parameter values from the command line.
echo
echo "Please fill in the config settings to store in your parameters.json"
echo "Defaults are shown in parenthesis.  <Enter> to accept."
echo

read -p "Location (\"$DEFAULT_LOCATION\"): " LOCATION
LOCATION="${LOCATION:-$DEFAULT_LOCATION}"

while [[ -z "$DEVOPSUSERNAME" ]]
do
    read -p "Devops Username (normally email with Azure subscription): " DEVOPSUSERNAME
done

while [[ -z "$DEVOPSPAT" ]]
do
    read -p "Devops Personal Access Token (check readme for instructions to get): " DEVOPSPAT
done

while [[ -z "$GITPAT" ]]
do
    read -p "Github Personal Access Token (check readme for instructions to get): " GITPAT
done

read -p "Git Branch (\"$DEFAULT_GITBRANCH\"): " GITBRANCH
read -p "Base Resource Name (\"$DEFAULT_RESOURCEGROUP_NAME\"): " RESOURCEGROUP_NAME
# HASH=$( head /dev/urandom | tr -dc A-Za-z0-9 | head -c 6 ; echo '')
RESOURCEGROUP_NAME="${RESOURCEGROUP_NAME:-$DEFAULT_RESOURCEGROUP_NAME}"
COMMON_RESOURCEGROUP_NAME="${RESOURCEGROUP_NAME}Common"
COMMON_RESOURCEGROUP_LOCATION=$LOCATION

# read -p "sites_RigContainerApp_name (\"$DEFAULT_CONTAINER_APP_NAME\"): " CONTAINER_APP_NAME
# read -p "serverfarms_RigContainerPlan_name (\"$DEFAULT_CONTAINER_PLAN_NAME\"): " CONTAINER_PLAN_NAME
# read -p "registries_RigContainerRegistry_name (\"$DEFAULT_CONTAINER_REGISTRY_NAME\"): " CONTAINER_REGISTRY_NAME
# read -p "config_web_name (\"$DEFAULT_WEB_CONFIG_NAME\"): " WEB_CONFIG_NAME
# read -p "hostNameBindings (\"$DEFAULT_HOST_NAME_BINDING\"): " HOST_NAME_BINDING
# read -p "appInsightsName (\"$DEFAULT_APP_INSIGHTS_NAME\"): " APP_INSIGHTS_NAME

echo

# read -p "location (\"$DEFAULT_DATABASE_LOCATION_NAME\"): " DATABASE_LOCATION_NAME
# read -p "serverName (\"$DEFAULT_DATABASE_SERVER_NAME\"): " DATABASE_SERVER_NAME
# read -p "databaseName (\"$DEFAULT_DATABASE_DB_NAME\"): " DATABASE_DB_NAME
# read -p "administratorLogin (\"$DEFAULT_DATABASE_ADMIN_USERNAME\"): " DATABASE_ADMIN_USERNAME
# read -p "administratorLoginPassword (\"$DEFAULT_DATABASE_ADMIN_PASSWORD\"): " DATABASE_ADMIN_PASSWORD
echo


# Assign the default values if the user didn't enter any value.
CONTAINER_APP_NAME="${CONTAINER_APP_NAME:-$DEFAULT_CONTAINER_APP_NAME}"
CONTAINER_PLAN_NAME="${CONTAINER_PLAN_NAME:-$DEFAULT_CONTAINER_PLAN_NAME}"
CONTAINER_REGISTRY_NAME="${CONTAINER_REGISTRY_NAME:-$DEFAULT_CONTAINER_REGISTRY_NAME}"
WEB_CONFIG_NAME="${WEB_CONFIG_NAME:-$DEFAULT_WEB_CONFIG_NAME}"
HOST_NAME_BINDING="${HOST_NAME_BINDING:-$DEFAULT_HOST_NAME_BINDING}"
APP_INSIGHTS_NAME="${APP_INSIGHTS_NAME:-$DEFAULT_APP_INSIGHTS_NAME}"
GITBRANCH="${GITBRANCH:-$DEFAULT_GITBRANCH}"
IMAGETAG_PREFIX="unstable-"
if [ "${GITBRANCH}" == "master" ]; then IMAGETAG_PREFIX=""; fi


# DATABASE_LOCATION_NAME="${DATABASE_LOCATION_NAME:-$DEFAULT_DATABASE_LOCATION_NAME}"
# DATABASE_SERVER_NAME="${DATABASE_SERVER_NAME:-$DEFAULT_DATABASE_SERVER_NAME}"
# DATABASE_DB_NAME="${DATABASE_DB_NAME:-$DEFAULT_DATABASE_DB_NAME}"
# DATABASE_ADMIN_USERNAME="${DATABASE_ADMIN_USERNAME:-$DEFAULT_DATABASE_ADMIN_USERNAME}"
# DATABASE_ADMIN_PASSWORD="${DATABASE_ADMIN_PASSWORD:-$DEFAULT_DATABASE_ADMIN_PASSWORD}"

#get project id from given project name


# Build the parameters.json file using the above parameters.
PARAM_FILE="output/parameters.json"
cp templates/parameters.json $PARAM_FILE
#FIND A COMMAND THAT WORKS FOR BOTH LINUX AND MAC 
sed -i'' -e "s/CONTAINER_APP_NAME/${CONTAINER_APP_NAME}/g" $PARAM_FILE
sed -i'' -e "s/CONTAINER_PLAN_NAME/${CONTAINER_PLAN_NAME}/g" $PARAM_FILE
sed -i'' -e "s/CONTAINER_REGISTRY_NAME/${CONTAINER_REGISTRY_NAME}/g" $PARAM_FILE
sed -i'' -e "s/WEB_CONFIG_NAME/${WEB_CONFIG_NAME}/g" $PARAM_FILE
sed -i'' -e "s/HOST_NAME_BINDING/${HOST_NAME_BINDING}/g" $PARAM_FILE
sed -i'' -e "s/APP_INSIGHTS_NAME/${APP_INSIGHTS_NAME}/g" $PARAM_FILE

# sed -i '' "s/DATABASE_LOCATION_NAME/${DATABASE_LOCATION_NAME}/g" $PARAM_FILE
# sed -i '' "s/DATABASE_SERVER_NAME/${DATABASE_SERVER_NAME}/g" $PARAM_FILE
# sed -i '' "s/DATABASE_DB_NAME/${DATABASE_DB_NAME}/g" $PARAM_FILE
# sed -i '' "s/DATABASE_ADMIN_USERNAME/${DATABASE_ADMIN_USERNAME}/g" $PARAM_FILE
# sed -i '' "s/DATABASE_ADMIN_PASSWORD/${DATABASE_ADMIN_PASSWORD}/g" $PARAM_FILE

sed -i'' -e "s/COMMON_RESOURCEGROUP_NAME/${COMMON_RESOURCEGROUP_NAME}/g" $PARAM_FILE
sed -i'' -e "s/COMMON_RESOURCEGROUP_LOCATION/${COMMON_RESOURCEGROUP_LOCATION}/g" $PARAM_FILE

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
sed -i'' -e "s~GITBRANCH~${GITBRANCH}~g" $PARAM_FILE
sed -i'' -e "s~COMMON_CONTAINERREGISTRY_IMAGETAG_PREFIX~${IMAGETAG_PREFIX}~g" $PARAM_FILE


# Display an output message and end the script.
echo "Saved parameters.json!"
echo