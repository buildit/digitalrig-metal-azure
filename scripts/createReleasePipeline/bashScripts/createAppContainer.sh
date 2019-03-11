#! /bin/bash

az appservice plan create --resource-group $1 \
--name $2-plan \
--is-linux \
--sku B1

az webapp create --resource-group $1 \
--plan $2-plan \
--name $2 \
--runtime "python|2.7"

az webapp config container set --resource-group $1 \
--name $2 \
--docker-custom-image-name $3/$4 \
--docker-registry-server-url https://$3