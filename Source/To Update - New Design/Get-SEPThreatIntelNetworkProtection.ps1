function Get-SepThreatIntelNetworkProtection {
    <#
    .SYNOPSIS
        Provide information whether a given URL/domain has been blocked by any of Symantec technologies
    .DESCRIPTION
        Provide information whether a given URL/domain has been blocked by any of Symantec technologies.
        These technologies include Antivirus (AV), Intrusion Prevention System (IPS) and Behavioral Analysis & System Heuristics (BASH)
    .PARAMETER domain
        Specify one or many URL/domain to check
    .OUTPUTS
        PSObject
    .EXAMPLE
        Get-SepThreatIntelNetworkProtection -domain nicolascoolman.eu
        Gathers information whether the URL/domain has been blocked by any of Symantec technologies
    .EXAMPLE
        "nicolascoolman.eu","google.com" | Get-SepThreatIntelNetworkProtection
        Gathers somains from pipeline by value whether the URLs/domains have been blocked by any of Symantec technologies
    #>

    [CmdletBinding()]
    param (
        # Mandatory domain name
        [Parameter(
            Mandatory,
            ValueFromPipeline = $true)]
        [Alias('domain', 'url')]
        [string[]]
        $network
    )

    begin {
        # Init
        $BaseURL = $($script:configuration.BaseURL)
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
        $array_network = @()
        foreach ($n in $network) {
            $params = @{
                Uri             = 'https://' + $BaseURL + "/v1/threat-intel/protection/network/" + $n
                Method          = 'GET'
                Headers         = $Headers
                UseBasicParsing = $true
            }
            $Response = Invoke-RestMethod @params
            $array_network += $Response
        }
        return $array_network
    }
}
