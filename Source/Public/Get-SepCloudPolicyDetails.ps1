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
        [Parameter()]
        [string]
        $Policy_UUID,

        # Policy version
        [Parameter()]
        [string]
        $Policy_Version,

        # Exact policy name
        [Parameter(
            ValueFromPipeline,
            Mandatory
        )]
        [string[]]
        [Alias("Name")]
        $Policy_Name
    )

    begin {
        # Init
        $array_resp = @()
    }

    process {
        # iterating through policy_name list if more than one obj
        foreach ($p in $Policy_Name) {
            # Get list of all SEP Cloud policies
            $obj_policies = (Get-SepCloudPolices).policies 
            $obj_policy = ($obj_policies | Where-Object { $_.name -eq "$p" })

            # Use specific version or by default latest
            if ($Policy_version -ne "") {
                $obj_policy = $obj_policy | Where-Object {
                    $_.name -eq "$p" -and $_.policy_version -eq $Policy_Version
                }
            } else {
                $obj_policy = ($obj_policy | Sort-Object -Property policy_version -Descending | Select-Object -First 1)
            }

            $Policy_UUID = ($obj_policy).policy_uid
            $Policy_Version = ($obj_policy).policy_version
            $BaseURL = (GetConfigurationPath).BaseUrl
            $URI = 'https://' + $BaseURL + "/v1/policies/$Policy_UUID/versions/$Policy_Version"
            # Get token
            $Token = Get-SEPCloudToken  

            if ($null -ne $Token) {
                $Body = @{}
                $Headers = @{
                    Host          = $BaseURL
                    Accept        = "application/json"
                    Authorization = $Token
                    Body          = $Body
                }
                $Resp = Invoke-RestMethod -Method GET -Uri $URI -Headers $Headers -Body $Body -UseBasicParsing 
                $array_resp += $Resp
            }
        }
    }

    end {
        return $array_resp
    }
}