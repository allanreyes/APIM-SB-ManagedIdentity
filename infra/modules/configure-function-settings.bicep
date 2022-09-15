@description('The name of the Function App instance')
param functionAppName string

@description('The name of the CosmosDB instance')
param cosmosAccountName string

@description('The Service Bus Namespace Host Name')
param sbHostName string

resource functionAppInstance 'Microsoft.Web/sites@2021-03-01' existing = {
  name: functionAppName
}

resource cosmosDBInstance 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' existing = {
  name: cosmosAccountName
}

resource appsettings 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: functionAppInstance
  name: 'appsettings'
  properties: {
    CosmosDbConnectionString: cosmosDBInstance.listConnectionStrings().connectionStrings[0].connectionString
    SBConnectionString__fullyQualifiedNamespace: sbHostName
  }
}

