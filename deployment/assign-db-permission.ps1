param(
    [Parameter(Mandatory)]
    [ValidateLength(5,128)]
    [string]$appName,
    [Parameter(Mandatory)]
    [ValidatePattern('(\{|\()?[A-Za-z0-9]{4}([A-Za-z0-9]{4}\-?){4}[A-Za-z0-9]{12}(\}|\()?')]
    [string]$appId,
    [Parameter(Mandatory)]
    [ValidatePattern('(\{|\()?[A-Za-z0-9]{4}([A-Za-z0-9]{4}\-?){4}[A-Za-z0-9]{12}(\}|\()?')]
    [string]$clientId,
    [Parameter(Mandatory)]
    [ValidateLength(5,128)]
    [string]$clientSecret,
    [Parameter(Mandatory)]
    [ValidateLength(5,128)]
    [string]$sqlServerName,
    [Parameter(Mandatory)]
    [ValidateLength(5,128)]
    [string]$sqlDatabaseName,
    [Parameter(Mandatory)]
    [ValidatePattern('(\{|\()?[A-Za-z0-9]{4}([A-Za-z0-9]{4}\-?){4}[A-Za-z0-9]{12}(\}|\()?')]
    [string]$tenantId
)
. $PSScriptRoot\helper-functions.ps1

Get-AccessToken -TenantID $tenantId -ServicePrincipalId $clientId -ServicePrincipalPwd $clientSecret `
    -OutVariable token -resourceAppIdURI 'https://database.windows.net/' | Out-null

$sqlServerFQN = "$($sqlServerName).database.windows.net"
$conn = new-object System.Data.SqlClient.SqlConnection
$conn.ConnectionString = "Server=tcp:$($sqlServerFQN),1433;Initial Catalog=$($sqlDatabaseName);Persist Security Info=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" 
$conn.AccessToken = $token

$sid = ConvertTo-Sid -objectId $appId

Write-SqlNonQuery -connection $conn -stmt @"
DECLARE @username VARCHAR(60)
SET @username = '$appName'

DECLARE @stmt VARCHAR(MAX)

SET @stmt = '
IF NOT EXISTS(SELECT 1 FROM sys.database_principals WHERE name =''' + @username +''')
BEGIN
    CREATE USER [' + @username + '] WITH DEFAULT_SCHEMA=[dbo], SID = $sid, TYPE = E;
END
IF IS_ROLEMEMBER(''db_owner'',''' + @username + ''') = 0
BEGIN
    ALTER ROLE db_owner ADD MEMBER ['+ @username +']
END'
EXEC(@stmt)
"@ | Out-Null 
$conn.Close()
