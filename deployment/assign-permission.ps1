<#
Grants an Azure service (web app or virtual machine) access to either Microsoft Graph API or Azure AD API.
#>
param(
    [Parameter(Mandatory)]
    [ValidateSet("graph", "aad")]
    $api,
    [Parameter(Mandatory)]
    $clientDisplayName,
    [Parameter(Mandatory)]
    $permissionName
)
$ErrorActionPreference = 'stop'
$apiApplicationId = if ($api -eq 'aad') {
    '00000002-0000-0000-c000-000000000000'
} else {
    '00000003-0000-0000-c000-000000000000'
}

$ManagedIdentitiesServicePrincipal = Get-AzureADServicePrincipal -Filter "displayName eq '$clientDisplayName'"
$GraphServicePrincipal = Get-AzureADServicePrincipal -Filter "appId eq '$apiApplicationId'"
$AppRole = $GraphServicePrincipal.AppRoles | Where-Object {$_.Value -eq $permissionName -and $_.AllowedMemberTypes -contains "Application"}
Write-host "Granting permission '$($AppRole.DisplayName)' to client '$($ManagedIdentitiesServicePrincipal.DisplayName)' on API resource '$($GraphServicePrincipal.DisplayName)'."
$ErrorActionPreference = 'silentlycontinue'
New-AzureAdServiceAppRoleAssignment `
    -ObjectId $ManagedIdentitiesServicePrincipal.ObjectId `
    -PrincipalId $ManagedIdentitiesServicePrincipal.ObjectId `
    -ResourceId $GraphServicePrincipal.ObjectId `
    -Id $AppRole.Id -ErrorAction SilentlyContinue | Out-Null

$ErrorActionPreference = 'stop'

$assignment = Get-AzureADServiceAppRoleAssignment -ObjectId $GraphServicePrincipal.ObjectId `
    | Where-Object {$_.Id -eq $AppRole.Id -and $_.PrincipalId -eq $ManagedIdentitiesServicePrincipal.ObjectId}

if (-not($assignment)) {
    Write-Error "Could not make assignment."
}

Write-Host "Assignment OK, object id is $($assignment.ObjectId)"