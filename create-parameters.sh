#!/bin/bash

# Read the environment name from the command line arguments.
environment_name=$1
if [[ -z "$environment_name" ]]; then
	echo "Usage: $0 <environment_name>"
	exit 1
fi


# Show a welcome message.
echo
echo "Please fill in the config settings to store in your parameters.$environment_name.json"
echo 'Defaults are shown in parenthesis.  <Enter> to accept.'
echo


# Set the default values for the parameter variables.
default_container_app_name="RigContainerApp"
default_container_plan_name="RigContainerPlan"
default_container_registry_name="RigContainerRegistry"
default_web_config_name="RigWebAppConfig"
default_host_name_binding="rigcontainerapp.azurewebsites.net"

default_database_location_name="Central US"
default_database_server_name="testservername"
default_database_db_name="testdatabase"
default_database_admin_login="azuresqladmin"
default_database_admin_password="***REMOVED***"


# Read the parameter values from the command line.
read -p "sites_RigContainerApp_name (\"$default_container_app_name\"): " container_app_name
read -p "serverfarms_RigContainerPlan_name (\"$default_container_plan_name\"): " container_plan_name
read -p "registries_RigContainerRegistry_name (\"$default_container_registry_name\"): " container_registry_name
read -p "config_web_name (\"$default_web_config_name\"): " web_config_name
read -p "hostNameBindings (\"$default_host_name_binding\"): " host_name_binding

read -p "location (\"$default_database_location_name\"): " database_location_name
read -p "serverName (\"$default_database_server_name\"): " database_server_name
read -p "databaseName (\"$default_database_db_name\"): " database_db_name
read -p "administratorLogin (\"$default_database_admin_login\"): " database_admin_login
read -p "administratorLoginPassword (\"$default_database_admin_password\"): " database_admin_password
echo


# Assign the default values if the user didn't enter any value.
container_app_name="${container_app_name:-$default_container_app_name}"
container_plan_name="${container_plan_name:-$default_container_plan_name}"
container_registry_name="${container_registry_name:-$default_container_registry_name}"
web_config_name="${web_config_name:-$default_web_config_name}"
host_name_binding="${host_name_binding:-$default_host_name_binding}"

database_location_name="${database_location_name:-$default_database_location_name}"
database_server_name="${database_server_name:-$default_database_server_name}"
database_db_name="${database_db_name:-$default_database_db_name}"
database_admin_login="${database_admin_login:-$default_database_admin_login}"
database_admin_password="${database_admin_password:-$default_database_admin_password}"


# Build the parameters.json file using the above parameters.
cat << EOF > parameters.$environment_name.json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "sites_RigContainerApp_name": {
            "value": "${container_app_name}"
        },
        "serverfarms_RigContainerPlan_name": {
            "value": "${container_plan_name}"
        },
        "registries_RigContainerRegistry_name": {
            "value": "${container_registry_name}"
        },
        "config_web_name": {
            "value": "${web_config_name}"
        },
        "hostNameBindings": {
            "value": "${host_name_binding}"
        },
        "location": {
            "value": "${database_location_name}"
        },
        "serverName": {
            "value": "${database_server_name}"
        },
        "databaseName": {
            "value": "${database_db_name}"
        },
        "administratorLogin": {
            "value": "${database_admin_login}"
        },
        "administratorLoginPassword": {
            "value": "${database_admin_password}"
        }
    }
}
EOF


# Display a output message and end the script.
echo "Saved parameters.$environment_name.json!"
echo