function Get-SepCloudPolicyDetails {

    <# TODO finish Get-SepCloudPolicyDetails description
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
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
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $Token = Get-SEPCloudToken
        $obj_policies = (Get-SepCloudPolices).policies
        $Body = @{}
        $Headers = @{
            Host          = $BaseURL
            Accept        = "application/json"
            Authorization = $Token
            Body          = $Body
        }
        # Get list of all SEP Cloud policies and get only the one with the correct name
        $obj_policy = ($obj_policies | Where-Object { $_.name -eq "$Policy_Name" })
    }

    process {
        if ($null -eq $Policy_version ) {
            $obj_policy = ($obj_policy | Sort-Object -Property policy_version -Descending | Select-Object -First 1)
            $Policy_Version = ($obj_policy).policy_version
        }


        $Policy_UUID = ($obj_policy).policy_uid
        $URI = 'https://' + $BaseURL + "/v1/policies/$Policy_UUID/versions/$Policy_Version"

        $Resp = Invoke-RestMethod -Method GET -Uri $URI -Headers $Headers -Body $Body -UseBasicParsing


        $Resp
    }
}
