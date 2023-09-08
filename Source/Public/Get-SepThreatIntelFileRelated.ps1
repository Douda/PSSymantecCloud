function Get-SepThreatIntelFileRelated {
    <#
    .SYNOPSIS
        Provide related file for a given file
    .DESCRIPTION
        Provide related file for a given file
    .INPUTS
        sha256
    .OUTPUTS
        PSObject
    .PARAMETER file_sha256
        Specify one or many sha256 hash
    .EXAMPLE
        PS C:\PSSymantecCloud> "eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d" | Get-SepThreatIntelFileRelated

        file                                                             related
        ----                                                             -------
        eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d {@{iocType=File; iocValues=System.Object[]; relation=byProcessChain}, @{iocType=File; iocValues=System.Object[]; relation=bySignature}}
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
                Uri             = 'https://' + $BaseURL + "/v1/threat-intel/related/file/" + $f
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
