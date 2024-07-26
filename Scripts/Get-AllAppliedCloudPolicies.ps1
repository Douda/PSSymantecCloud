<#
    As of 11/07/2024 it is not possible to get the assigned locations/groups for a policy from the policy URI endpoint
    The current workaround is to get the list of all groups and then get the policies assigned to each group
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $path
)

# Get all policies and groups
$policiesSummary = Get-SEPCloudPolicesSummary
$groups = Get-SEPCloudGroup
$groupsList = @()

# Get all groups and their assigned policies
foreach ($group in $groups.device_groups) {
    $groupPolicies = Get-SEPCloudGroupPolicies -GroupID $group.id

    $obj = [PSCustomObject]@{
        group    = $group
        Policies = $groupPolicies.policies
    }

    $groupsList += $obj

    # Wait for 10 seconds to avoid rate limiting
    Write-Host "Waiting for 10 seconds to avoid rate limiting"
    Write-Host "Group: $($group.name)"
    Write-Host "---------------------------------"
    Start-Sleep -Seconds 10
}

# Extract the policies from the list
$flattenedList = $groupsList | ForEach-Object {
    $group = $_.group
    $_.policies | ForEach-Object {
        $policy = $_
        $policy.target_rules | ForEach-Object {
            # Create a new object for each target rule, copying the policy and group details
            [PSCustomObject]@{
                GroupName                 = $group.name
                GroupId                   = $group.id
                GroupFullPathName         = $group.fullPathName
                PolicyName                = $policy.name
                PolicyType                = $policy.policy_type
                PolicyUid                 = $policy.policy_uid
                PolicyVersion             = $policy.policy_version
                PolicyTargetApplyLevel    = $policy.target_apply_level
                PolicyTargetRuleName      = $_.name
                PolicyTargetRuleEnabled   = $_.enabled
                PolicyTargetRuleSortOrder = $_.sort_order
            }
        }
    }
} | ConvertTo-FlatObject

# Check if a path was provided
if ($Path) {
    # Export the flattened list to a CSV file at the specified path
    $flattenedList | Export-Csv -Path $Path -NoTypeInformation
} else {
    # Return the flattened list if no path is provided
    return $flattenedList
}
