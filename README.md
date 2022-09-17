# Exposing Azure Service Bus using API Management

This tutorial will walk through setting up API Management policy for sending data to Azure Service Bus. The API Management will use Managed Identity to access the Service Bus REST APIs. A Function will be triggered when a message is queued in Service Bus, and it will write message data to Cosmos DB. The Function App will use Managed Identity to get access to Service Bus. This is a typical integration scenario leveraging APIs.

Below architecture is deployed in this demonstration.

![Integration Architecture](media/s8.png)

Azure Services used:

1. API Management
1. Service Bus
1. Function App
1. Cosmos DB

The client can be simulated using curl, or any other tool that can send HTTP request to APIM gateway.

## Deploy solution to Azure

Login to your Azure in your terminal.

```bash
az login
```

To check your subscription.

```bash
az account show
```

Run the deployment. The deployment will create the resource group "rg-\<Name suffix for resources\>". 

```bash
az deployment sub create --name "<unique deployment name" --location "<Your Chosen Location>" --template-file infra/main.bicep --parameters name="<Name suffix for resources>" publisherEmail="<Publisher Email for APIM>" publisherName="<Publisher Name for APIM>" 
```

The following deployments will run:

![deployment times](media/s11.png)

NOTE: The APIM deployment can take over an hour to complete.

## Validate Deployment

1. Use Curl or another tool to send a request as shown below to the "demo-queue" created during deployment. Make sure to send in the API key in the header "Ocp-Apim-Subscription-Key".

    ```bash
    curl -X POST https://<Your APIM Gateway URL>/sb-operations/demo-queue -H 'Ocp-Apim-Subscription-Key:<Your APIM Subscription Key>'   -H 'Content-Type: application/json' -d '{ "date" : "2022-09-17", "id" : "1", "data" : "Sending data to APIM->Service Bus->Trigger Function->write to CosmosDB" }'
    ```

    ![Test APIM gateway](media/s9.png)

1. Go to your deployment of Cosmos DB in Azure Portal, click on Data Explorer, select "demo-database" and the "demo-container”, click Items. Select the first item and view the content. It will match the data submitted to the APIM gateway in step 1.
    
    ![Data in Cosmos DB](media/s10.png)

## Disclaimer

The code and deployment biceps are for demonstration purposes only.

