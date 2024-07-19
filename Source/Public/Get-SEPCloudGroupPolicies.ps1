function Get-SEPCloudGroupPolicies {
    <#
    .SYNOPSIS
        Gathers list of policies applied for a device group
    .DESCRIPTION
        Gathers list of policies applied for a device group
    .PARAMETER GroupID
        ID of the group to get policies for
    .EXAMPLE
    (Get-SEPCloudGroupPolicies).policies | ft

        name                                policy_type          policy_uid                           policy_version target_apply_level target_rules
        ----                                -----------          ----------                           -------------- ------------------ ------------
        Default Deny List Policy            Deny List            56cae937-03ef-4090-8542-09fff526ee18              1 inherited          {@{name=Default; enabled=True; sort_order=9999…
        Default System Policy               System               15de78e5-053a-485e-b919-5f0987dd1cf2              1 inherited          {@{name=Default; enabled=True; sort_order=9999…
        Default Antimalware Policy          Malware Protection   4566b529-0d5e-402a-bfe9-8765a56a98f9              1 inherited          {@{name=Default; enabled=True; sort_order=9999…
        Default Intrusion Prevention Policy Intrusion Prevention 1d91f033-a50a-4e2c-bb67-eaec84e5cdb5              1 inherited          {@{name=Default; enabled=True; sort_order=9999…
        Default Adaptive Protection Policy  Adaptive Protection  3e6126ff-708d-405a-8d94-334da61743a4              2 inherited          {@{name=Default; enabled=True; sort_order=9999…
        Default Device Control Policy       Device Control       6001cf8a-045b-4075-bccb-aa9131cc19dc              1 inherited          {@{name=Default; enabled=True; sort_order=9999…
        Default MEM Policy                  Exploit Protection   375aab38-1bab-44d2-a59c-55c4e2976a8a              1 inherited          {@{name=Default; enabled=True; sort_order=9999…
        Default Firewall Policy             Firewall             1acb4fa5-bf0a-445d-9d3a-4f0a09c72623              1 inherited          {@{name=Default; enabled=True; sort_order=9999…
        Custom Allow list                   Allow List           6b5567d3-0e81-4c01-9fea-17b8b36171ce              1 direct             {@{name=Custom location; enabled=True; sort_orde…
        Default Network Integrity Policy    Network Integrity    14fe8776-4f35-45da-a89b-76aaa3456b6e              1 inherited          {@{name=Default; enabled=True; sort_order=9999…
    #>

    [CmdletBinding()]
    param (
        # Group ID
        [Parameter(
            ValueFromPipelineByPropertyName = $true
        )]
        [String]
        $GroupID
    )

    begin {
        # Init
        $BaseURL = $($script:configuration.BaseURL)
        $URI = 'https://' + $BaseURL + "/v1/device-groups"
        $Token = (Get-SEPCloudToken).Token_Bearer
    }

    process {
        if ($GroupID) {
            $URI = $URI + '/' + $GroupID + "/policies"
        }

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
            $response = Invoke-SEPCloudWebRequest @params
        } catch {
            "Error : " + $_
        }

        return $response
    }
}
