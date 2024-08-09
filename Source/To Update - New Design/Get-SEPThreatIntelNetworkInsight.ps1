function Get-SepThreatIntelNetworkInsight {
    <#
    .SYNOPSIS
        Provide domain insight enrichments for a given domain
    .DESCRIPTION
        Provide domain insight enrichments for a given domain
    .INPUTS
        domain
    .OUTPUTS
        PSObject
    .PARAMETER domain
        Specify one or many domain
    .EXAMPLE
        PS C:\PSSymantecCloud> Get-SepThreatIntelNetworkInsight -domain "elblogdeloscachanillas.com.mx/s3sy8rq10/ophn.png"

        network         : elblogdeloscachanillas.com.mx/s3sy8rq10/ophn.png
        threatRiskLevel : @{level=10}
        categorization  : @{categories=System.Object[]}
        reputation      : BAD
        targetOrgs      : @{topCountries=System.Object[]; topIndustries=System.Object[]}
    .EXAMPLE
    "elblogdeloscachanillas.com.mx/s3sy8rq10/ophn.png" | Get-SepThreatIntelNetworkInsight
    #>

    [CmdletBinding()]
    param (
        # Mandatory domain
        [Parameter(
            Mandatory,
            ValueFromPipeline = $true)]
        [Alias('URL')]
        [string[]]
        $domain
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
        $array_domain = @()
        foreach ($d in $domain) {
            $params = @{
                Uri             = 'https://' + $BaseURL + "/v1/threat-intel/insight/network/" + $d
                Method          = 'GET'
                Headers         = $Headers
                UseBasicParsing = $true
            }
            $Response = Invoke-RestMethod @params
            $array_domain += $Response
        }
        return $array_domain
    }
}
