function Get-SepThreatIntelFileProtection {
    <#
    .SYNOPSIS
        Provide information whether a given file has been blocked by any of Symantec technologies
    .DESCRIPTION
        Provide information whether a given file has been blocked by any of Symantec technologies.
        These technologies include Antivirus (AV), Intrusion Prevention System (IPS) and Behavioral Analysis & System Heuristics (BASH)
    .INPUTS
        sha256
    .OUTPUTS
        PSObject
    .PARAMETER file_sha256
        Specify one or many sha256 hash
    .EXAMPLE
        Get-SepThreatIntelFileProtection -file_sha256 eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d
        Gathers information whether the file with sha256 has been blocked by any of Symantec technologies
    .EXAMPLE
        "eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d","eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8e" | Get-SepThreatIntelFileProtection
        Gathers sha from pipeline by value whether the files with sha256 have been blocked by any of Symantec technologies
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
        $array_file_sha256 = @()
        foreach ($f in $file_sha256) {
            $params = @{
                Uri             = 'https://' + $BaseURL + "/v1/threat-intel/protection/file/" + $f
                Method          = 'GET'
                Headers         = $Headers
                UseBasicParsing = $true
            }
            $Response = Invoke-RestMethod @params
            $array_file_sha256 += $Response
        }
        return $array_file_sha256
    }
}
