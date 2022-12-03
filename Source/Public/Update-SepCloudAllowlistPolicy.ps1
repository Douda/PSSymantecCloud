function Update-SepCloudAllowlistPolicy {
    # TODO to finish; test cmd-let
    param (
        # Policy UUID
        [Parameter()]
        [string]
        $Policy_UUID,

        # Policy version
        [Parameter()]
        [string]
        [Alias("Version")]
        $Policy_Version,

        # Exact policy name
        [Parameter(
            ValueFromPipeline,
            Mandatory
        )]
        [string]
        [Alias("Name")]
        $Policy_Name
    )

    begin {
        # Init
        $BaseURL = (GetConfigurationPath).BaseUrl
    }

    process {
        # Get list of all SEP Cloud policies, gather only the one based on name
        $obj_policies = (Get-SepCloudPolices).policies
        $obj_policy = ($obj_policies | Where-Object { $_.name -eq "$Policy_Name" })

        # Use specific version or by default latest
        if ($Policy_version -ne "") {
            $obj_policy = $obj_policy | Where-Object {
                $_.name -eq "$Policy_Name" -and $_.policy_version -eq $Policy_Version
            }
        } else {
            $obj_policy = ($obj_policy | Sort-Object -Property policy_version -Descending | Select-Object -First 1)
        }

        # Set UUID & version from policy & URI
        $Policy_UUID = ($obj_policy).policy_uid
        $Policy_Version = ($obj_policy).policy_version
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
            $Response = Invoke-RestMethod -Method PATCH -Uri $URI -Headers $Headers -Body $Body -UseBasicParsing
        }
    }

    end {
        return $Response
    }

}
