function Get-AccessToken {
    [CmdletBinding()]
    [OutputType([string])]
    PARAM (
        [Parameter(Mandatory)]
        [String]$TenantID,
        [Parameter(Mandatory)]
        [string]$ServicePrincipalId,
        [Parameter(Mandatory)]
        [string]$ServicePrincipalPwd,
        [Parameter(Mandatory)]
        $resourceAppIdURI
    )
    Try {
        $tokenResponse = Invoke-RestMethod -Method Post -UseBasicParsing `
            -Uri "https://login.windows.net/$($TenantID)/oauth2/token" `
            -Body @{
                resource=$resourceAppIdURI
                client_id=$ServicePrincipalId
                grant_type='client_credentials'
                client_secret=$ServicePrincipalPwd
            } -ContentType 'application/x-www-form-urlencoded'
        
        if ($tokenResponse) {
            Write-debug "Access token type is $($tokenResponse.token_type), expires $($tokenResponse.expires_on)"
            $Token = $tokenResponse.access_token
        } else {
            Write-Error "Could not get access token"
        }
    }
    Catch {
        Throw $_
        $ErrorMessage = 'Failed to aquire Azure AD token.'
        Write-Error -Message 'Failed to aquire Azure AD token'
    }
    $Token
}

function ConvertTo-Sid {
    param (
        [string]$objectId
    )
    [guid]$guid = [System.Guid]::Parse($objectId)
    foreach ($byte in $guid.ToByteArray()) {
        $byteGuid += [System.String]::Format("{0:X2}", $byte)
    }
    return "0x" + $byteGuid
}

function Write-SqlNonQuery {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [System.Data.SqlClient.SqlConnection]$connection,
        [Parameter(Mandatory)]
        $stmt
    )
    $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $sqlCmd.CommandText = $stmt
    Write-Debug $stmt
    $sqlCmd.Connection = $connection
    if ($connection.State -ne 'Open') {
        $connection.Open()
    }
    $sqlCmd.ExecuteNonQuery()
}