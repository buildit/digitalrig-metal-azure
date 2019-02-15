#!/bin/bash

echo 'Please fill in the config settings to store in your parameters.env.json'
echo 'Defaults are shown in parenthesis.  <Enter> to accept.'
echo
read -p 'sites_RigContainerApp_name ("RigContainerApp"): ' sites_RigContainerApp_name
read -p 'serverfarms_RigContainerPlan_name ("RigContainerPlan"): ' serverfarms_RigContainerPlan_name
read -p 'config_web_name ("RigWebAppConfig"): ' config_web_name
read -p 'registries_RigContainerRegistry_name ("RigContainerRegistry"): ' registries_RigContainerRegistry_name
read -p 'hostNameBindings ("rigcontainerapp.azurewebsites.net"): ' hostNameBindings
echo

cat << EOF > parameters.env.json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "sites_RigContainerApp_name": {
            "value": "${sites_RigContainerApp_name:-RigContainerApp}"
        },
        "serverfarms_RigContainerPlan_name": {
            "value": "${serverfarms_RigContainerPlan_name:-RigContainerPlan}"
        },
        "config_web_name": {
            "value": "${config_web_name:-RigWebAppConfig}"
        },
        "registries_RigContainerRegistry_name": {
            "value": "${registries_RigContainerRegistry_name:-RigContainerRegistry}"
        },
        "hostNameBindings": {
            "value": "${hostNameBindings:-rigcontainerapp.azurewebsites.net}"
        }
    }
}
EOF

echo 'Saved parameters.json!'
echo