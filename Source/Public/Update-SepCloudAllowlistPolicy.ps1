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
    .PARAMETER Policy_UUID
        Optional parameter - GUID of the policy. Optional. The function can gathers the UUID from the policy name
    .PARAMETER Policy_Version
        Optional parameter - Version of the policy to update. By default, latest version selected
    .PARAMETER Policy_Name
        Exact name of the policy to update
    .PARAMETER ExcelFile
        Path fo the Excel file that contains updated information on Allow list to update
        Takes Excel template from Export-SepCloudAllowListPolicyToExcel function
    .NOTES
        Currently supports only filehash/filename
        TODO update NOTES when more options will be supported
    .EXAMPLE
        TODO review & add more examples
        Get-SepCloudPolicyDetails
        Update-SepCloudAllowlistPolicy -policy "My Policy" -ExcelFile .\WorkstationsAllowList.xlsx
        the file MyAllowList.xlsx can be generated from : get-sepcloudpolicyDetails -name "Workstations Allow List Policy" | Export-SepCloudAllowListPolicyToExcel -Path .\Data\WorkstationsAllowList.xlsx
    #>


    # TODO to finish; test ParameterSetName Policy
    param (
        # Policy UUID
        [Parameter(
            ParameterSetName = 'Policy'
        )]
        [string]
        $Policy_UUID,

        # Policy version
        [Parameter(
            ParameterSetName = 'Policy'
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
        # TODO remove hardcoded value
        $Policy_Name = "AB - Testing - Servers - Core - Allow List Policy",

        # Excel file to import data from
        [Parameter(
            # Mandatory
            # TODO add this parameter as mandatory once development is done
        )]
        [string]
        [Alias("Excel")]
        # TODO remove hardcoded excel path for dev
        $excel_path = "C:\Amcor\Module\Workstations_allowlist.xlsx"
    )

    # Verify parameters
    switch ($PSBoundParameters.Keys) {
        'Policy_Version' {
            # Merge cloud policy with excel file
            $obj_policy = Merge-CloudPolicyWithExcel -Excel $excel_path -Policy_Name $Policy_Name -Policy_Version $Policy_Version
        }
        Default {
            #Get latest cloud policy if no version specified
            $CloudPolicy = Get-SepCloudPolicyDetails -Name $Policy_Name
        }
    }

    # Excel file to import data from
    $excel_obj_policy = Get-ExcelAllowListObject -Path $excel_path


    # Converting PSObj to json
    $Body = $obj_policy | ConvertTo-Json -Depth 10

    # Get token for API query
    $Token = Get-SEPCloudToken

    # API query
    if ($null -ne $Token) {
        $Headers = @{
            Host           = $BaseURL
            "Content-Type" = "application/json"
            Accept         = "application/json"
            Authorization  = $Token
        }
        #$Response = Invoke-RestMethod -Method PATCH -Uri $URI -Headers $Headers -Body $Body -UseBasicParsing
        # TODO uncomment API query
    } else {
        Write-Error "Invalid or empty token - exit"
        break
    }
    # TODO See if we need to remove return once finished
    return $Response
}
