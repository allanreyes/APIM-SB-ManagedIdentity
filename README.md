# Exposing Azure Service Bus REST API using API Management and Managed Identity

## Create Resource Group

```bash
az login # Login via browser
az group create -n "<Your Resource Group Name>" -l "<Your Resource Location>"
```

## Deploy API Management

```bash
az deployment group create --resource-group "<Your Resource Group Name>" --template-file deploy/apim.bicep --parameters publisherEmail="<Your Email Address>" publisherName="<Your Name>" apimServiceName="<Unique APIM Service Name>"
```

## Deploy Service Bus

```bash
az deployment group create --resource-group "<Your Resource Group Name>" --template-file deploy/service-bus.bicep --parameters nameSpace="<Unique Service Bus Namespace>"
```
