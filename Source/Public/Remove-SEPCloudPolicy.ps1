function Remove-SEPCloudPolicy {

    <#
    .SYNOPSIS
        Removes a SEP Cloud policy from a device group
    .DESCRIPTION
        Removes a SEP Cloud policy from a device group.
        Must include a specific location (also called policy target rule)
    .PARAMETER policyName
        Name of the policy to apply
    .PARAMETER policyVersion
        Version of the policy to apply.
        If not provided, the latest version will be used
    .PARAMETER targetRules
        Alias: location
        Location (policy target rule) to apply the policy to
        If not provided, the default location will be used
    .PARAMETER deviceGroupID
        Device group ID to apply the policy to
    .OUTPUTS
        None
    .EXAMPLE
        Remove-SEPCloudPolicy -policyName "My Policy" -location "Default" -deviceGroupID "123456"
        Removes the latest version of the SEP Cloud policy named "My Policy" to the device group with ID "123456" at the location "Default"
    #>



    param (
        # Policy UUID
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $policyName,

        # Policy version
        [Parameter()]
        [string]
        [Alias("Version")]
        $policyVersion,

        # target rules
        [Parameter(
            Mandatory = $true
        )]
        [string]
        [Alias("target_rules")]
        [Alias("location")]
        $targetRule = "Default",

        # device group ID
        [Parameter(
            Mandatory = $true
        )]
        [string]
        [Alias("device_group_id")]
        $deviceGroupID
    )

    begin {
        # Init
        $BaseURL = $($script:configuration.BaseURL)
        $Token = (Get-SEPCloudToken).Token_Bearer
        $objPolicies = (Get-SEPCloudPolicesSummary).policies
    }

    process {
        # Get list of all SEP Cloud policies and get only the one with the correct name
        $objPolicy = ($objPolicies | Where-Object { $_.name -eq "$policyName" })

        # If policy version is not provided, get the latest version
        if ($null -eq $policyVersion ) {
            $objPolicy = ($objPolicy | Sort-Object -Property policy_version -Descending | Select-Object -First 1)
        }

        # Set variables
        $policyVersion = ($objPolicy).policy_version
        $policyUUID = ($objPolicy).policy_uid
        $URI = 'https://' + $BaseURL + "/v1/policies/$policyUUID/versions/$policyVersion/device-groups"

        $params = @{
            Method  = 'DELETE'
            Uri     = $uri
            Headers = @{
                # Host          = $baseUrl
                Accept        = "application/json"
                Authorization = $Token
            }
            Body    = @{
                target_rules     = @($targetRule) # Ensure target_rules is an array
                override         = $true
                device_group_ids = @($deviceGroupID) # Ensure device_group_ids is an array
            }
        }

        try {
            $response = Invoke-SEPCloudWebRequest @params
        } catch {
            "Error : " + $_
        }

        return $response
    }
}
