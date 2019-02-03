param (
    [Parameter(Mandatory)]
    $deploymentName,
    [Parameter(Mandatory=$false)]
    $resourceGroup="msisample-rg",
    [Parameter(Mandatory=$false)]
    $location='westeurope',
    [Parameter(Mandatory=$false)]
    $subscription='5c45e8ca-a796-4870-b93e-379b1aa6a28f'
)

Select-AzureRmSubscription -Subscription $subscription | out-null
Get-AzureRmResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue | out-null
if ($?) {
    Write-host "Resource group $resourceGroup exists."
} else {
    Write-host "Creating resource group $resourceGroup"
    New-AzureRmResourceGroup -Name $resourceGroup -Location $location
}    
Write-host "Starting deployment $deploymentName"
New-AzureRmResourceGroupDeployment `
    -Name $deploymentName `
    -ResourceGroupName $resourceGroup `
    -TemplateFile "$psscriptroot\azuredeploy.json"
