@description('The Service Bus Namespace')
param nameSpace string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The pricing tier of this Service Bus Namespace')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Basic'

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
  name: nameSpace
  location: location
  sku: {
    capacity: 1
    name: sku
    tier: sku
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    zoneRedundant: false
  }
}

resource sbAuthorizationRules 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2021-11-01' = {
  name: 'myDemoClient'
  parent: serviceBusNamespace
  properties: {
    rights: [
      'Listen'
      'Send'
    ]
  }
}

resource sbNetworkRuleSet 'Microsoft.ServiceBus/namespaces/networkRuleSets@2021-06-01-preview' = {
  name: 'default'
  parent: serviceBusNamespace
  properties: {
    defaultAction: 'Allow'
    ipRules: []
    publicNetworkAccess: 'Enabled'
    virtualNetworkRules: []
  }
}

resource sbQueues 'Microsoft.ServiceBus/namespaces/queues@2021-06-01-preview' = {
  name: 'demo-queue'
  parent: serviceBusNamespace
  properties: {
    deadLetteringOnMessageExpiration: false
    defaultMessageTimeToLive: 'P14D'
    enableBatchedOperations: true
    enableExpress: false
    enablePartitioning: false
    lockDuration: 'PT30S'
    maxDeliveryCount: 10
    requiresDuplicateDetection: false
    requiresSession: false
  }
}
