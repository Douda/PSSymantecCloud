function Get-SepThreatIntelCveProtection {
    <#
    .SYNOPSIS
        Provide information whether a given CVE has been blocked by any of Symantec technologies
    .DESCRIPTION
        Provide information whether a given URL/domain has been blocked by any of Symantec technologies.
        These technologies include Antivirus (AV), Intrusion Prevention System (IPS) and Behavioral Analysis & System Heuristics (BASH).

    .PARAMETER network
        Specify one domain

    .EXAMPLE
        Get-SepThreatIntelCveProtection -cve CVE-2023-35311
    #>

    [CmdletBinding()]
    param (
        # Mandatory cve
        [Parameter(
            Mandatory,
            ValueFromPipeline = $true)]
        [Alias('vuln')]
        [Alias('vulnerability')]
        [string[]]
        $cve
    )

    begin {
        # Init
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $Token = Get-SEPCloudToken
    }

    process {
        # $URI in the process block for pipeline support
        $URI = 'https://' + $BaseURL + "/v1/threat-intel/protection/cve/$cve"

        if ($null -ne $Token) {
            # HTTP body content containing all the queries
            $Body = @{}
            $Headers = @{
                Host          = $BaseURL
                Accept        = "application/json"
                Authorization = $Token
                Body          = $Body
            }
            $Response = Invoke-RestMethod -Method GET -Uri $URI -Headers $Headers -Body $Body -UseBasicParsing
            $Response
        }
    }
}
