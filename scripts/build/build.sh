#set up resources used in build
until $(az login  > loginOutput.json ); do
    printf 'waiting to log in' 
    sleep 5
done
sed -i '1,2d;$d' loginOutput.json
echo "logged in successful"
cat ./loginOutput.json
#create resource group
az group create --name $groupName --location "Central US"
#what does the service connection need to be created
# serviceConnectionId=uuidgen
# tennantId=#get from az login
# subscriptionId=#get from az login
# resourceGroup=$groupName
# serviceName="service connection " can be anything
# #create service connection 
curl -u $userCred \ #user credentials should be form username:PAT
    --header "Content-Type: application/json" \
    --request POST \
    --data "@createServiceConnectionData.json" \
    "https://dev.azure.com/$orgName/$projectId/_apis/serviceendpoint/endpoints?api-version=5.0-preview.2" | jq '.' > createServiceOutput.json


#creat build pipeline
curl -u $userCred \
    --header "Content-Type: application/json" \
    --request POST \
    --data "@buildTemplate.json" \
    "https://dev.azure.com/$orgName/$projectName/_apis/build/definitions?api-version=5.0" | jq '.' > buildOutput.json

