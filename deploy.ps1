# Connect-AzAccount
# Get-AzContext
# Set-AzContext

$params = @{
    suffix = "allanreyes"
    publisherEmail= 'allanreyes@microsoft.com'
    publisherName = 'Allan Reyes'
    functionAppRepo = 'https://github.com/allanreyes/APIM-SB-ManagedIdentity.git'
}

New-AzSubscriptionDeployment -Name "APIMSBtestDeployment" `
    -Location canadacentral `
    -TemplateFile ".\infra\main.bicep" `
    -TemplateParameterObject $params `
    -AsJob

