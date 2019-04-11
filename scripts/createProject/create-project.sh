#!/bin/bash

DATAPATH=./scripts/createProject/data/
OUTPUTPATH=./scripts/createProject/outputs/
TEMPLATEPATH=./scripts/createProject/templates/

mkdir -p $DATAPATH
mkdir -p $OUTPUTPATH

# Get parameters

while [[ -z "$DEVOPSUSERNAME" ]]
do
    read -p "Devops Username (normally email with Azure subscription): " DEVOPSUSERNAME
done

while [[ -z "$DEVOPSPAT" ]]
do
    read -p "Devops Personal Access Token (check readme for instructions to get): " DEVOPSPAT
done

USERCRED="$DEVOPSUSERNAME:$DEVOPSPAT"

while [[ -z "$ORGNAME" ]]
do
    read -p "Devops Organiztion Name: " ORGNAME
done

while [[ -z "$PROJECTNAME" ]]
do
    read -p "Devops Project Name: " PROJECTNAME
done

#create new project
echo "creating new project"
DATAFILE="createProjectData.json"
OUTPUTFILE="createProjectOutput.json"
TEMPLATEFILE="createProjectTemplate.json"
[ -e $DATAPATH/$DATAFILE ] && rm $DATAPATH/$DATAFILE
[ -e $OUTPUTPATH/$OUTPUTFILE ] && rm $OUTPUTPATH/$OUTPUTFILE
cp $TEMPLATEPATH/$TEMPLATEFILE $DATAPATH/$DATAFILE

#inject values into datafile
sed -i'' -e " s|\${projectName}|$PROJECTNAME|" $DATAPATH/$DATAFILE
until $(curl -u "$USERCRED" --header "Content-Type: application/json" --request POST --data "@$DATAPATH/$DATAFILE" "https://dev.azure.com/$ORGNAME/_apis/projects?api-version=5.0" | jq '.' > $OUTPUTPATH/$OUTPUTFILE); do
    printf "waiting to create project"
    sleep 5
done
sleep 30
echo ""
OUTPUTFILE="getProject.json"
until $(curl -u "$USERCRED" --request GET "https://dev.azure.com/$ORGNAME/_apis/projects/$PROJECTNAME?api-version=5.0" | jq '.' > $OUTPUTPATH/$OUTPUTFILE); do
    printf "waiting to create project"
    sleep 5
done
PROJECTID=$(jq -r '.id' < $OUTPUTPATH/$OUTPUTFILE)

#set parameters
PARAM_FILE="output/parameters.json"
[ -e $PARAM_FILE ] && rm $PARAM_FILE
cp templates/parameters.json $PARAM_FILE

sed -i'' -e "s/DEVOPSUSERNAME/${DEVOPSUSERNAME}/g" $PARAM_FILE
sed -i'' -e "s/DEVOPSPAT/${DEVOPSPAT}/g" $PARAM_FILE
sed -i'' -e "s/ORGNAME/${ORGNAME}/g" $PARAM_FILE
sed -i'' -e "s/PROJECTNAME/${PROJECTNAME}/g" $PARAM_FILE
sed -i'' -e "s/PROJECTID/${PROJECTID}/g" $PARAM_FILE
