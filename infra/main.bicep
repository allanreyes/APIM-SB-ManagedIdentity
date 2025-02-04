targetScope = 'subscription'

@minLength(1)
@maxLength(16)
@description('Prefix for all resources, i.e. {name}storage')
param suffix string

@minLength(1)
@description('The email address of the owner of the APIM service')
param publisherEmail string

@description('The name of the owner of the APIM service')
@minLength(1)
param publisherName string

@minLength(1)
@description('Primary location for all resources')
param location string = deployment().location

@minLength(1)
@description('Git repository that contain the function app files')
param functionAppRepo string


resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${suffix}'
  location: location
}

module apim './modules/apim.bicep' = {
  name: '${rg.name}-apim'
  scope: rg
  params: {
    apimServiceName: 'apim-${toLower(suffix)}'
    publisherEmail: publisherEmail
    publisherName: publisherName
    location: rg.location
  }
}

module servicebus './modules/service-bus.bicep' = {
  name: '${rg.name}-servicebus'
  scope: rg
  params: {
    nameSpace: 'sb-${toLower(suffix)}'
    location: rg.location
  }
}

module cosmosdb './modules/cosmosdb.bicep' = {
  name: '${rg.name}-cosmosdb'
  scope: rg
  params: {
    accountName: 'cosmos-${toLower(suffix)}'
    location: rg.location
  }
}

module function './modules/function.bicep' = {
  name: '${rg.name}-function'
  scope: rg
  params: {
    appName: 'func-${toLower(suffix)}'
    location: rg.location
  }
}

module roleAssignmentAPIMSenderSB './modules/configure/roleAssign-apim-service-bus.bicep' = {
  name: '${rg.name}-roleAssignmentAPIMSB'
  scope: rg
  params: {
    apimServiceName: apim.outputs.apimServiceName
    sbNameSpace: servicebus.outputs.sbNameSpace
  }
  dependsOn: [
    apim
    servicebus
  ]
}

module roleAssignmentFcuntionReceiverSB './modules/configure/roleAssign-function-service-bus.bicep' = {
  name: '${rg.name}-roleAssignmentFunctionSB'
  scope: rg
  params: {
    functionAppName: function.outputs.functionAppName
    sbNameSpace: servicebus.outputs.sbNameSpace

  }
  dependsOn: [
    function
    servicebus
  ]
}

module configurFunctionAppSettings './modules/configure/configure-function.bicep' = {
  name: '${rg.name}-configureFunction'
  scope: rg
  params: {
    functionAppName: function.outputs.functionAppName
    cosmosAccountName: cosmosdb.outputs.cosmosDBAccountName
    sbHostName: servicebus.outputs.sbHostName
    repositoryUrl: functionAppRepo
  }
  dependsOn: [
    function
    servicebus
    cosmosdb
  ]
}

module configurAPIM './modules/configure/configure-apim.bicep' = {
  name: '${rg.name}-configureAPIM'
  scope: rg
  params: {
    apimServiceName: apim.outputs.apimServiceName
    sbEndpoint: servicebus.outputs.sbEndpoint
  }
  dependsOn: [
    apim
  ]
}

output apimServideBusOperation string = '${apim.outputs.apimEndpoint}/sb-operations/'
