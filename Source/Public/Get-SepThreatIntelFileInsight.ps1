function Get-SepThreatIntelFileInsight {
    <#
    .SYNOPSIS
        Provide file insight enrichments for a given file
    .DESCRIPTION
        Provide file insight enrichments for a given file
    .INPUTS
        sha256
    .OUTPUTS
        PSObject
    .PARAMETER file_sha256
        Specify one or many sha256 hash
    .EXAMPLE
        PS C:\PSSymantecCloud> Get-SepThreatIntelFileInsight -file_sha256 eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d

        file       : eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d
        reputation : BAD
        prevalence : Hundreds
        firstSeen  : 2018-04-13
        lastSeen   : 2023-09-03
        targetOrgs :
    .EXAMPLE
    "eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d" | Get-SepThreatIntelFileInsight
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
                Uri             = 'https://' + $BaseURL + "/v1/threat-intel/insight/file/" + $f
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
