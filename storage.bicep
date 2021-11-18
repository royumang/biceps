@minLength(3)
@maxLength(11)
param storagePrefix string

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageSKU string = 'Standard_LRS'

param location string = resourceGroup().location

var uniqueStorageName = '${storagePrefix}${uniqueString(resourceGroup().id)}'

resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: uniqueStorageName
  location: location
  sku: {
    name: storageSKU
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

output storageEndpoint object = stg.properties.primaryEndpoints
The Bicep file requires one parameter called storagePrefix with 3 to 11 characters.

You can put the file anywhere in the repository. The workflow sample in the next section assumes the Bicep file is named azuredeploy.bicep, and it’s stored at the root of your repository.

Create workflow
The workflow file must be stored in the .github/workflows folder at the root of your repository. The workflow file extension can be either .yml or .yaml.

From your GitHub repository, select Actions from the top menu.
Select New workflow.
Select set up a workflow yourself.
Rename the workflow file if you prefer a different name other than main.yml. For example: deployBicepFile.yml.
Replace the content of the yml file with the following
on: [push]
name: Azure ARM
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:

      # Checkout code
    - uses: actions/checkout@main

      # Log into Azure
    - uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

      # Deploy Bicep file
    - name: deploy
      uses: azure/arm-deploy@v1
      with:
        subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION }}
        resourceGroupName: ${{ secrets.AZURE_RG }}
        template: ./azuredeploy.bicep
        parameters: storagePrefix=mystore
        failOnStdErr: false
