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
        Write-Host "Authentication OK"
        return $true
        else {
            Write-Host "Authentication failed"
            return $false
        }
    }
}
