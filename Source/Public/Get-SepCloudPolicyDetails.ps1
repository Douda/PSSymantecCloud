function Get-SepCloudPolicyDetails {

    <#
    .SYNOPSIS
        Gathers detailed information on SEP Cloud policy
    .DESCRIPTION
        Gathers detailed information on SEP Cloud policy
    .PARAMETER Policy_UUID
        Policy UUID
    .PARAMETER Policy_Version
        Policy version
    .PARAMETER Policy_Name
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
        $Policy_UUID,

        # Policy version
        [Parameter()]
        [string]
        [Alias("Version")]
        $Policy_Version,

        # Exact policy name
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [string[]]
        [Alias("Name")]
        $Policy_Name
    )

    begin {
        # Init
        $BaseURL = $($script:configuration.BaseURL)
        $Token = (Get-SEPCloudToken).Token_Bearer
        $obj_policies = (Get-SEPCloudPolicesSummary).policies
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
        $obj_policy = ($obj_policies | Where-Object { $_.name -eq "$Policy_Name" })

        if ($null -eq $Policy_version ) {
            $obj_policy = ($obj_policy | Sort-Object -Property policy_version -Descending | Select-Object -First 1)
        }

        $Policy_Version = ($obj_policy).policy_version
        $Policy_UUID = ($obj_policy).policy_uid
        $URI = 'https://' + $BaseURL + "/v1/policies/$Policy_UUID/versions/$Policy_Version"

        $Resp = Invoke-RestMethod -Method GET -Uri $URI -Headers $Headers -Body $Body -UseBasicParsing

        return $Resp
    }
}
