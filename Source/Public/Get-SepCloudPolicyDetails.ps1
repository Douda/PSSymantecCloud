function Get-SepCloudPolicyDetails {

    <#
    .SYNOPSIS
        Gathers detailed information on SEP Cloud policy
    .DESCRIPTION
        Gathers detailed information on SEP Cloud policy
    .PARAMETER policyUUID
        Policy UUID
    .PARAMETER policyVersion
        Policy version
    .PARAMETER policyName
        Exact policy name
    .OUTPUTS
        PSObject
    .EXAMPLE
    Get-SepCloudPolicyDetails -name "My Policy"
    Gathers detailed information on the latest version SEP Cloud policy named "My Policy"
    .EXAMPLE
    Get-SepCloudPolicyDetails -name "My Policy" -version 1
    Gathers detailed information on the version 1 of SEP Cloud policy named "My Policy"
    .EXAMPLE
    "My Policy","My Policy 2" | Get-SepCloudPolicyDetails
    Piped strings are used as policy name to gather detailed information on the latest version SEP Cloud policy named "My Policy" & "My Policy 2"
    #>


    param (
        # Policy UUID
        [Parameter(
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        [Alias("policy_uid")]
        $policyUUID,

        # Policy version
        [Parameter()]
        [string]
        [Alias("Version")]
        $policyVersion,

        # Exact policy name
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [string[]]
        [Alias("Name")]
        $policyName
    )

    begin {
        # Init
        $BaseURL = $($script:configuration.BaseURL)
        $Token = (Get-SEPCloudToken).Token_Bearer
        $objPolicies = (Get-SEPCloudPolicesSummary).policies
        $Body = @{}
        $Headers = @{
            Host          = $BaseURL
            Accept        = "application/json"
            Authorization = $Token
            Body          = $Body
        }
    }

    process {
        # Get list of all SEP Cloud policies and get only the one with the correct name
        $objPolicy = ($objPolicies | Where-Object { $_.name -eq "$policyName" })

        if ($null -eq $policyVersion ) {
            $objPolicy = ($objPolicy | Sort-Object -Property policy_version -Descending | Select-Object -First 1)
        }

        $policyVersion = ($objPolicy).policy_version
        $policyUUID = ($objPolicy).policy_uid
        $URI = 'https://' + $BaseURL + "/v1/policies/$policyUUID/versions/$policyVersion"

        $params = @{
            Method  = 'GET'
            Uri     = $uri
            Headers = @{
                # Host          = $baseUrl
                Accept        = "application/json"
                Authorization = $token
            }
        }

        try {
            $response = Invoke-ABWebRequest @params
        } catch {
            "Error : " + $_
        }

        return $response
    }
}
