function New-EDRFullDump {

    <#
    .SYNOPSIS
        Sends a full dump command on an endpoint
    .DESCRIPTION
        Sends a full dump command on an endpoint
    .EXAMPLE
        New-EDRFullDump -ComputerName "computername"
        Sends a full dump command on an endpoint called "computername"
    .EXAMPLE
        New-EDRFullDump -ComputerName "computername" -Description "My description"
        Sends a full dump command on an endpoint with a description "My description"
    .EXAMPLE
        "computername" | New-EDRFullDump
        Sends a full dump command on an endpoint called "computername" from pipeline
    #>

    [CmdletBinding()]
    param (
        # ComputerName
        [Parameter(
            ValueFromPipeline = $true
        )]
        [string]
        [Alias("Hostname", "Computer")]
        $ComputerName,

        # description
        [string]
        $Description

    )

    begin {
        # Init
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $Token = (Get-SEPCloudToken).Token_Bearer
    }

    process {
        # Get Computer UID from ComputerName
        $Device_ID = (Get-SepCloudDevices -Computername $Computername).id
        $URI = 'https://' + $BaseURL + "/v1/commands/endpoint-search/fulldump"

        if ([string]::IsNullOrEmpty($Description)) {
            $message = "$ComputerName - Full Dump request"
            $Description = $message
        }
        $body = @{
            device_id   = $Device_ID
            description = $Description
        }

        $params = @{
            Uri             = $URI
            Method          = 'POST'
            Body            = $body | ConvertTo-Json
            Headers         = @{
                Host           = $BaseURL
                Accept         = "application/json"
                "Content-Type" = "application/json"
                Authorization  = $Token
            }
            UseBasicParsing = $true
        }

        $Resp = Invoke-RestMethod @params

        return $Resp
    }
}
