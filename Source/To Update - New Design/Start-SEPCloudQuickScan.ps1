function Start-SepCloudQuickScan {
    <#
    .SYNOPSIS
        Initiate a quick scan command on SEP Cloud managed devices
    .DESCRIPTION
        Initiate a quick scan command on SEP Cloud managed devices
    .EXAMPLE
        Start-SepCloudQuickScan -ComputerName MyComputer

        Initiate a quick scan command on a specific computer
    .EXAMPLE
        Start-SepCloudQuickScan -ComputerName Computer01,Computer02
    .EXAMPLE
        Start-SepCloudQuickScan -ComputerName (Get-Content -Path .\ComputerList.txt)

        Initiate a quick scan command on a list of computers
    .EXAMPLE
        Get-Content -Path .\ComputerList.txt | Start-SepCloudQuickScan

        Initiate a quick scan command on a list of computers
    #>

    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('Computer', 'Device', 'Hostname', 'Host')]
        [Collections.Generic.List[System.String]]
        $ComputerName
    )

    begin {
        # Init
        $BaseURL = $($script:configuration.BaseURL)
        $Token = (Get-SEPCloudToken).Token_Bearer
    }

    process {
        # Get list of devices ID from ComputerNames
        $Device_ID_list = New-Object System.Collections.Generic.List[string]
        foreach ($Computer in $ComputerName) {
            $Device_ID = (Get-SEPCloudDevice -Computername $Computer).id
            $Device_ID_list += $Device_ID
        }

        $URI = 'https://' + $BaseURL + "/v1/commands/scans/quick"
        $body = @{
            device_ids = $Device_ID_list
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

        if ($resp.status -eq 200) {
            return $Resp.results.data
        } else {
            Write-Warning -Message "Error: $Resp"
            return $Resp
        }
    }
}
