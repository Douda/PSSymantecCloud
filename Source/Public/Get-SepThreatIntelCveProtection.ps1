function Get-SepThreatIntelCveProtection {
    <#
    .SYNOPSIS
        Provide information whether a given CVE has been blocked by any of Symantec technologies
    .DESCRIPTION
        Provide information whether a given URL/domain has been blocked by any of Symantec technologies.
        These technologies include Antivirus (AV), Intrusion Prevention System (IPS) and Behavioral Analysis & System Heuristics (BASH)
    .PARAMETER cve
        Specify one or many CVE to check
    .EXAMPLE
        Get-SepThreatIntelCveProtection -cve CVE-2023-35311
        Gathers information whether CVE-2023-35311 has been blocked by any of Symantec technologies
    .EXAMPLE
        "CVE-2023-35311","CVE-2023-35312" | Get-SepThreatIntelCveProtection
        Gathers cve from pipeline by value whether CVE-2023-35311 & CVE-2023-35312 have been blocked by any of Symantec technologies
    #>

    [CmdletBinding()]
    param (
        # Mandatory cve
        [Parameter(
            Mandatory,
            ValueFromPipeline = $true)]
        [Alias('vuln', 'vulnerability')]
        [string[]]
        $cve
    )

    begin {
        # Init
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $Token = (Get-SEPCloudToken).Token_Bearer
        # HTTP body content containing all the queries
        $Body = @{}
        $Headers = @{
            Host          = $BaseURL
            Accept        = "application/json"
            Authorization = $Token
            Body          = $Body
        }
    }

    process {
        $array_cve = @()
        foreach ($c in $cve) {
            $URI = 'https://' + $BaseURL + "/v1/threat-intel/protection/cve/" + $c
            $Response = Invoke-RestMethod -Method GET -Uri $URI -Headers $Headers -Body $Body -UseBasicParsing
            $array_cve += $Response
        }
        return $array_cve
    }
}
