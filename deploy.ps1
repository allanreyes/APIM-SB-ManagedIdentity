# Connect-AzAccount
# Get-AzContext
# Set-AzContext

$params = @{
    suffix = "allanreyes"
    publisherEmail= 'allanreyes@microsoft.com'
    publisherName = 'Allan Reyes'
}

New-AzSubscriptionDeployment -Name "APIMSBtestDeployment" `
    -Location canadacentral `
    -TemplateFile ".\infra\main.bicep" `
    -TemplateParameterObject $params `
    -AsJob

