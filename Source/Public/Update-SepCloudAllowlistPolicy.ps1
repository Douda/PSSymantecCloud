function Update-SepCloudAllowlistPolicy {
    <#
    .SYNOPSIS
        Updates Symantec Allow List policy using an excel file
    .DESCRIPTION
        Gathers Allow List policy information from an Excel file generated from Export-SepCloudPolicyToExcel function
        You can manually add lines to the Excel file, and the updated Excel will be used to add new exceptions to the Allow list policy of your choice
    .INPUTS
        - Excel file generated from Export-SepCloudPolicyToExcel function
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
        Takes Excel template from Export-SepCloudPolicyToExcel function
    .NOTES
        Currently supports only filehash/filename
        TODO update NOTES when more options will be supported
    .EXAMPLE
        TODO review & add more examples
        Get-SepCloudPolicyDetails
        Update-SepCloudAllowlistPolicy -policy "My Policy" -ExcelFile .\WorkstationsAllowList.xlsx
        the file MyAllowList.xlsx can be generated from : get-sepcloudpolicyDetails -name "Workstations Allow List Policy" | Export-SepCloudPolicyToExcel -Path .\Data\WorkstationsAllowList.xlsx
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
        # TODO remove hardcoded info
        $Policy_Name = "AB - Testing - Allowlist",

        # Excel file to import data from
        [Parameter(
            # Mandatory
            # TODO add this parameter as mandatory once development is done
        )]
        [string]
        [Alias("Excel")]
        # TODO remove hardcoded excel path for dev
        $excel_path = ".\Data\Workstations_allowlist.xlsx"
    )
    # Get policy details to compare with Excel file
    # Use specific version or by default latest
    if ($Policy_version -ne "") {
        $obj_policy = Get-SepCloudPolicyDetails -Policy_Name $Policy_Name -Policy_Version $Policy_Version
    }

    $obj_policy = Get-SepCloudPolicyDetails -Policy_Name $Policy_Name

    # Import excel report as a structured object with
    $obj_policy_excel = Get-ExcelAllowListObject -Path $excel_path

    # Initialize structured obj that will be later converted
    # to HTTP JSON Body with "add" and "remove" hive
    $obj_body = [UpdateAllowlist]::new()

    # Comparison starts here
    <#
        As there are no built-in ways to compare 2 deeply nested PSObject
        Parse through every allow list type (Applications/certificates/etc...) and compare as followed :
        - If exception type (file/hash/etc) found in both excel / baseline policy : no changes
        - If found in Excel but not in baseline : set it in "add" hive
        - If found in baseline but not Excel : set it in "remove" hive
    #>

    # Comparison with "Applications" tab
    $policy_sha2 = $obj_policy.features.configuration.applications.processfile
    $excel_sha2 = $obj_policy_excel.Applications.processfile
    # Parsing first excel object
    foreach ($line in $excel_sha2) {
        # if sha2 appears in both lists
        if ($policy_sha2.sha2.contains($line.sha2)) {
            # No changes needed
            # TODO can remove sha2 from policy obj to reduce 2nd pass load
            continue
        } else {
            # if sha2 only in excel list
            # set the sha to the "add" hive
            $obj_body.add.AddProcessFile(
                $line.sha2,
                $line.name
            )
        }
    }
    # Parsing then policy object
    foreach ($line in $policy_sha2) {
        # if sha2 appears only in policy (so not in Excel)
        if (-not $excel_sha2.sha2.contains($line.sha2)) {
            # set the sha to the "remove" hive
            $obj_body.remove.AddProcessFile(
                $line.sha2,
                $line.name
            )
        }
    }

    # Comparison ends here
    # ...

    # At this stage $obj_body contains the full import of excel allow list files/directories etc..
    # Now we need to compare this obj_body to the policy we'll update to remove duplicates

    # Converting PSObj to json
    $Body = $obj_body | ConvertTo-Json -Depth 10
    # Get token
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
