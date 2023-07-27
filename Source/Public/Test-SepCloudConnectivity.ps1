function Test-SepCloudConnectivity {
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
