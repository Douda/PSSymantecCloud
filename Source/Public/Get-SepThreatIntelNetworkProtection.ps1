function Get-SepThreatIntelNetworkProtection {
    <#
    .SYNOPSIS
        Provide information whether a given URL/domain has been blocked by any of Symantec technologies
    .DESCRIPTION
        Provide information whether a given URL/domain has been blocked by any of Symantec technologies.
        These technologies include Antivirus (AV), Intrusion Prevention System (IPS) and Behavioral Analysis & System Heuristics (BASH).

    .PARAMETER network
        Specify one domain

    .EXAMPLE
        Get-SepThreatIntelNetworkProtection -domain nicolascoolman.eu
    #>

    [CmdletBinding()]
    param (
        # Mandatory domain name
        [Parameter(
            Mandatory,
            ValueFromPipeline = $true)]
        [Alias('domain')]
        [Alias('URL')]
        [string[]]
        $network
    )

    begin {
        # Init
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $Token = (Get-SEPCloudToken).Token_Bearer
        $Body = @{}
        $Headers = @{
            Host          = $BaseURL
            Accept        = "application/json"
            Authorization = $Token
            Body          = $Body
        }
    }

    process {
        # $URI in the process block for pipeline support
        $URI = 'https://' + $BaseURL + "/v1/threat-intel/protection/network/$network"

        $Response = Invoke-RestMethod -Method GET -Uri $URI -Headers $Headers -Body $Body -UseBasicParsing
        $Response

    }
}
