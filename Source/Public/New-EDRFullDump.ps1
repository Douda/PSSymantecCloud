function New-EDRFullDump {

    <# TODO write help
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
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
        $Device_ID = (Get-SEPCloudDevice -Computername $Computername).id
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
