function Update-SepCloudAllowlistPolicy {
    <# TODO verify description
    .SYNOPSIS
        Updates Symantec Allow List policy using an excel file
    .DESCRIPTION
        Gathers Allow List policy information from an Excel file generated from Export-SepCloudAllowListPolicyToExcel function
        You can manually add lines to the Excel file, and the updated Excel will be used to add new exceptions to the Allow list policy of your choice
    .INPUTS
        - Excel file generated from Export-SepCloudAllowListPolicyToExcel function
        - Policy name to update
        - OPTIONAL : policy version (default latest version)
    .PARAMETER Policy_Version
        Optional parameter - Version of the policy to update. By default, latest version selected
    .PARAMETER Policy_Name
        Exact name of the policy to update
    .PARAMETER ExcelFile
        Path fo the Excel file that contains updated information on Allow list to update
        Takes Excel template from Export-SepCloudAllowListPolicyToExcel function
    .EXAMPLE
        TODO review & add more examples
        Get-SepCloudPolicyDetails
        Update-SepCloudAllowlistPolicy -policy "My Policy" -ExcelFile .\WorkstationsAllowList.xlsx
        the file MyAllowList.xlsx can be generated from : get-sepcloudpolicyDetails -name "Workstations Allow List Policy" | Export-SepCloudAllowListPolicyToExcel -Path .\Data\WorkstationsAllowList.xlsx
    #>

    param (
        # Policy version
        [Parameter(
        )]
        [string]
        [Alias("Version")]
        $Policy_Version,

        # Exact policy name
        [Parameter(
            ValueFromPipeline
            # Mandatory
        )]
        [string]
        [Alias("PolicyName")]
        $Policy_Name,

        # Excel file to import data from
        [Parameter(
            # Mandatory
            # TODO add this parameter as mandatory once development is done
        )]
        [string]
        [Alias("Excel")]
        $excel_path
    )

    # init
    $BaseURL = (Get-ConfigurationPath).BaseUrl
    $Token = Get-SEPCloudToken
    # Get list of all versions of the SEP Cloud policy
    $obj_policy = ((Get-SepCloudPolices).policies | Where-Object { $_.name -eq "$Policy_Name" })


    switch ($PSBoundParameters.Keys) {
        'Policy_Version' {
            # Merge cloud policy with excel file with specified version
            $obj_merged_policy = Merge-SepCloudAllowList -Excel $excel_path -Policy_Name $Policy_Name -Policy_Version $Policy_Version
            $obj_policy = $obj_policy | Where-Object {
                $_.name -eq "$Policy_Name" -and $_.policy_version -eq $Policy_Version
            }
        }
        Default {}
    }

    if ($null -eq $PSBoundParameters['Policy_Version']) {
        # Merge cloud policy with excel file with latest version
        $obj_merged_policy = Merge-SepCloudAllowList -Excel $excel_path -Policy_Name $Policy_Name
        $obj_policy = ($obj_policy | Sort-Object -Property policy_version -Descending | Select-Object -First 1)
    }

    # Setup API query
    $Body = $obj_merged_policy | ConvertTo-Json -Depth 10
    $Policy_UUID = ($obj_policy).policy_uid
    $Policy_Version = ($obj_policy).policy_version
    $URI = 'https://' + $BaseURL + "/v1/policies/allow-list/$Policy_UUID/versions/$Policy_Version"

    # API query
    $Headers = @{
        Host           = $BaseURL
        "Content-Type" = "application/json"
        Accept         = "application/json"
        Authorization  = $Token
    }
    #$Response = Invoke-RestMethod -Method PATCH -Uri $URI -Headers $Headers -Body $Body -UseBasicParsing
    # TODO uncomment API query when development is done

    return $Response
}
