function Test-SepCloudConnectivity {
    <#
    .SYNOPSIS
        Test SEP Cloud connectivity
    .DESCRIPTION
        Test SEP Cloud connectivity. returns boolean $true if OK, $false if not
    .INPUTS
        None
    .OUTPUTS
        [boolean] $true or $false
    .EXAMPLE
        Test-SepCloudConnectivity
        Test SEP Cloud connectivity and return $true if OK, $false if not

    #>
    param (
    )

    if (Get-SEPCloudToken) {
        return Write-Host "Authentication OK"
        else {
            Write-Warning "Authentication failed - Use Clear-SepCloudAuthentication to clear your API token and try again"
            return $false
        }
    }
}
