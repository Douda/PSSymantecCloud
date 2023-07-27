function Get-SepThreatIntelFileProtection {
    <#
    .SYNOPSIS
        Provide information whether a given file has been blocked by any of Symantec technologies
    .DESCRIPTION
        Provide information whether a given file has been blocked by any of Symantec technologies.
        These technologies include Antivirus (AV), Intrusion Prevention System (IPS) and Behavioral Analysis & System Heuristics (BASH).

    .PARAMETER file_sha256
        Specify one sha256 hash

    .EXAMPLE
        Get-SepThreatIntelFileProtection -file_sha256 eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d
    #>

    [CmdletBinding()]
    param (
        # Mandatory file sha256
        [Parameter(
            Mandatory,
            ValueFromPipeline = $true)]
        [Alias('sha256')]
        [string[]]
        $file_sha256
    )

    begin {
        # Init
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $Token = Get-SEPCloudToken
    }

    process {
        # $URI in the process block for pipeline support
        $URI = 'https://' + $BaseURL + "/v1/threat-intel/protection/file/$file_sha256"

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
