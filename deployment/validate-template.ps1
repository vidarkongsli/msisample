param (
    [Parameter(Mandatory=$false)]
    $resourceGroup="msisample-validate-rg",
    [Parameter(Mandatory=$false)]
    $location='westeurope',
    [Parameter(Mandatory=$false)]
    $subscription='--subscription--guid--',
    [Parameter(Mandatory=$false)]
    [ValidateScript({test-path $_ -PathType Leaf})]
    $templateFile = "$PSScriptRoot\azuredeploy.json"
)

Select-AzureRmSubscription -Subscription $subscription | out-null
Get-AzureRmResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue | out-null
if ($?) {
    Write-host "Resource group $resourceGroup exists."
} else {
    Write-host "Creating resource group $resourceGroup"
    New-AzureRmResourceGroup -Name $resourceGroup -Location $location
}    
Write-host "Validating template"
Test-AzureRmResourceGroupDeployment `
    -ResourceGroupName $resourceGroup `
    -TemplateFile $templateFile `
    -TemplateParameterFile "$PSScriptRoot\validate.parameters.json"
