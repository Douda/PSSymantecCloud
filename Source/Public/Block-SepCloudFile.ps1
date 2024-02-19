function Block-SepCloudFile {
    <#
    .SYNOPSIS
        Quarantines one or many files on one or many SEP Cloud managed endpoint
    .DESCRIPTION
        Quarantines one or many files on one or many SEP Cloud managed endpoint
    .EXAMPLE
        Block-SepCloudFile -ComputerName MyComputer -sha256 0536B2E0ACF3EF1933CF326EB4B423902A9E12B9348A28A336516EE32C94E25B

        BLocks a specific file on a specific computer
        .EXAMPLE
        Block-SepCloudFile -ComputerName Computer01,Computer02 -sha256 0536B2E0ACF3EF1933CF326EB4B423902A9E12B9348A28A336516EE32C94E25B, 0536B2E0ACF3EF1933CF326EB4B423902A9E12B9348A28A336516EE32C94E25B
    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [Alias('Computer', 'Device', 'Hostname', 'Host')]
        [Collections.Generic.List[System.String]]
        $ComputerName,

        [Parameter()]
        [Alias('sha256')]
        [Collections.Generic.List[System.String]]
        $file_sha256
    )

    begin {
        # Init
        $BaseURL = $($script:configuration.BaseURL)
        $Token = (Get-SEPCloudToken).Token_Bearer
    }

    process {
        #Get list of devices ID from ComputerNames
        $Device_ID_list = New-Object System.Collections.Generic.List[string]
        foreach ($Computer in $ComputerName) {
            $Device_ID = (Get-SEPCloudDevice -Computername $Computer).id
            $Device_ID_list += $Device_ID
        }

        $URI = 'https://' + $BaseURL + "/v1/commands/files/contain"
        $body = @{
            device_ids = $Device_ID_list
            hash       = $file_sha256
        }

        $Headers = @{
            Host           = $BaseURL
            Accept         = "application/json"
            "Content-Type" = "application/json"
            Authorization  = $Token
        }

        $params = @{
            Uri             = $URI
            Method          = 'POST'
            Body            = $Body | ConvertTo-Json
            Headers         = $Headers
            UseBasicParsing = $true
        }

        try {
            $Resp = Invoke-RestMethod @params
        } catch {
            Write-Warning -Message "Error: $_"
        }

        return $Resp
    }
}
