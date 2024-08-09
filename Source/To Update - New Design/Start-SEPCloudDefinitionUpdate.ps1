function Start-SepCloudDefinitionUpdate {
    <#
    .SYNOPSIS
        Initiate a definition update request command on SEP Cloud managed devices
    .DESCRIPTION
        Initiate a definition update request command on SEP Cloud managed devices
    .EXAMPLE
        Start-SepCloudDefinitionUpdate -ComputerName MyComputer

        Initiate a definition update request command on a specific computer
    .EXAMPLE
        Start-SepCloudDefinitionUpdate -ComputerName Computer01,Computer02
    .EXAMPLE
        Start-SepCloudDefinitionUpdate -ComputerName (Get-Content -Path .\ComputerList.txt)

        Initiate a definition update request command on a list of computers
    .EXAMPLE
        Get-Content -Path .\ComputerList.txt | Start-SepCloudDefinitionUpdate

        Initiate a definition update request command on a list of computers
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
        #Get list of devices ID from ComputerNames
        $Device_ID_list = New-Object System.Collections.Generic.List[string]
        foreach ($Computer in $ComputerName) {
            $Device_ID = (Get-SEPCloudDevice -Computername $Computer).id
            $Device_ID_list += $Device_ID
        }

        $URI = 'https://' + $BaseURL + "/v1/commands/update_content"
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

        return $Resp
    }
}
