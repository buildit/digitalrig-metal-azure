#!/bin/bash

containerRegistry="${1}"

#pull the docker image
docker pull yeasy/simple-web

#find that image

IMG=`docker inspect --format="{{.Id}}" yeasy/simple-web`
echo ${IMG}
echo "$containerRegistry"

#Tag the docker image
docker tag ${IMG} ${containerRegistry}.azurecr.io/simple

#Login to ACR
az acr login --name ${containerRegistry} 

#Push the image to azurecr
docker push ${containerRegistry}.azurecr.io/simple