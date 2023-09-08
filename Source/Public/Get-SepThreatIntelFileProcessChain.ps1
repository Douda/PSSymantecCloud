function Get-SepThreatIntelFileProcessChain {
    <#
    .SYNOPSIS
        Provide topK process lineage enrichment for the provided file sha256.
    .DESCRIPTION
        Provide topK process lineage enrichment for the provided file sha256.
    .INPUTS
        sha256
    .OUTPUTS
        PSObject
    .PARAMETER file_sha256
        Specify one or many sha256 hash
    .EXAMPLE
        PS C:\PSSymantecCloud> $ProcessChain =  Get-SepThreatIntelFileProcessChain -file_sha256 eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d

        file                                                             chain
        ----                                                             -----
        eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d {@{parent=}}

        PS C:\PSSymantecCloud> $ProcessChain.chain

        parent
        ------
        @{parent=; file=18bba9ff311154415404e2fb16f3784e4c82b57ad110092ea5f9b76ed549e7cb; processName=fe392ea0a9f14s4dfeda8d9u0233a6ioq6e47a5n3.exe}

        .EXAMPLE
        "eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d" | Get-SepThreatIntelFileProcessChain
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
                Uri             = 'https://' + $BaseURL + "/v1/threat-intel/processchain/file/" + $f
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
