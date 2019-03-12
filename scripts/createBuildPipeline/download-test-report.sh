export AZURE_STORAGE_ACCOUNT=$1
export AZURE_STORAGE_KEY=$2
export BUILD_NUMBER=$3

export container_name=test-results
export blob_name="TestReport_${BUILD_NUMBER}.xml"
export destination_file=$(System.DefaultWorkingDirectory)/TestReport.xml

echo "Downloading the file..."
az storage blob download --container-name $container_name --name $blob_name --file $destination_file --output table

echo "Done"

echo $(ls)