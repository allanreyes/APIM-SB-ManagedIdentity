@description('The name of the function app that you wish to create.')
param appName string = 'func-${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The language worker runtime to load in the function app.')
param runtime string = 'dotnet'

var functionAppName = appName
var hostingPlanName = appName
var applicationInsightsName = appName
var functionWorkerRuntime = runtime

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
  kind: 'app'
  properties: {
    zoneRedundant: false
  }
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    httpsOnly: true
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    storageAccountRequired: false
  }
}

resource functionApp_config 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: functionApp
  name: 'web'

  properties: {
    appSettings: [
      {
        name: 'AzureWebJobsStorage'
        value: 'DefaultEndpointsProtocol=https;AccountName=;EndpointSuffix=;AccountKey='
      }
      {
        name: 'FUNCTIONS_EXTENSION_VERSION'
        value: '~4'
      }
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: applicationInsights.properties.InstrumentationKey
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: applicationInsights.properties.ConnectionString
      }
      {
        name: 'FUNCTIONS_WORKER_RUNTIME'
        value: functionWorkerRuntime
      }
    ]
    alwaysOn: true
    ftpsState: 'FtpsOnly'
    minTlsVersion: '1.2'
    netFrameworkVersion: 'v6.0'
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

output functionAppName string = functionApp.name
output functionResourceId string = functionApp.id
