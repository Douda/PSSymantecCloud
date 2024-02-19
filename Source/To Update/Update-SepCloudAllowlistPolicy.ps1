function Update-SepCloudAllowlistPolicy {
    <# TODO Update description with -add & sha/name parameters
    .SYNOPSIS
        Updates Symantec Allow List policy using an excel file
    .DESCRIPTION
        Gathers Allow List policy information from an Excel file generated from Export-SepCloudAllowListPolicyToExcel function
        You can manually add or remove lines to the Excel file, and the updated Excel will be used to add or remove new exceptions to the Allow list policy of your choice
    .INPUTS
        [string] Policy_Name
        [string] ExcelFile
        optional [string] Policy_Version
    .OUTPUTS
        [PSCustomObject] Policy
    .PARAMETER Policy_Version
        Optional parameter - Version of the policy to update. By default, latest version selected
    .PARAMETER Policy_Name
        Exact name of the policy to update
    .PARAMETER ExcelFile
        Path fo the Excel file that contains updated information on Allow list to update
        Takes Excel template from Export-SepCloudAllowListPolicyToExcel function
    .PARAMETER Add
        [switch] Add content to the policy. Supports only -sha2 and -name parameters
    .PARAMETER Remove
        [switch] Remove content from the policy. Supports only -sha2 and -name parameters
    .PARAMETER sha2
        [string] sha2 hash to add or remove from the policy
    .PARAMETER name
        [string] name of the file to add or remove from the policy
    .EXAMPLE
        First generate an excel file from the policy you want to update
        Get-SepCloudPolicyDetails -name "Workstations Allow List Policy" | Export-SepCloudAllowListPolicyToExcel -Path .\Data\WorkstationsAllowList.xlsx
        Manualy perform changes to the Excel file (add or remove exceptions)
        Then update the policy to reflect the changes to the cloud
        Update-SepCloudAllowlistPolicy -policy "Workstations Allow List Policy" -ExcelFile .\WorkstationsAllowList.xlsx
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByExcelFileLatestVersion')]
    param (
        # Policy version
        [Parameter(Mandatory = $true, ParameterSetName = 'ByExcelFileVersionSpecific')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ByHashVersionSpecific')]
        [string]
        [Alias("Version")]
        $Policy_Version,

        # Exact policy name
        # TODO : test if policy name provided exists
        [Parameter(Mandatory)]
        [Alias("PolicyName")]
        [string]
        $Policy_Name,

        # Excel file to import data from
        # TODO test if excel path provided exists
        [Parameter(Mandatory = $true, ParameterSetName = 'ByExcelFileLatestVersion')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ByExcelFileVersionSpecific')]
        [string]
        [Alias("Excel")]
        $excel_path,

        # Add Action to perform
        [Parameter(ParameterSetName = "ByHashVersionSpecific")]
        [Parameter(ParameterSetName = "ByHashLatestVersion")]
        [switch]$Add,

        # Remove Action to perform
        [Parameter(ParameterSetName = "ByHashVersionSpecific")]
        [Parameter(ParameterSetName = "ByHashLatestVersion")]
        [switch]$Remove,

        # Hash to add or remove
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ByHashVersionSpecific")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ByHashLatestVersion")]
        [ValidateScript({ # Validate sha2 hash format
                if ($_ -match "^[0-9a-f]{64}$") {
                    $true
                } else {
                    throw "Invalid hash"
                }
            })]
        [ValidateNotNullOrEmpty()]
        [Alias('hash')]
        [string]$sha2,

        # File name to add or remove
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ByHashVersionSpecific")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ByHashLatestVersion")]
        [ValidateNotNullOrEmpty()]
        [Alias('name')]
        [string]$file_name
    )

    # init
    $BaseURL = $($script:configuration.BaseURL)
    $Token = (Get-SEPCloudToken).Token_Bearer
    # Get list of all versions of the SEP Cloud policy
    $obj_policy = ((Get-SEPCloudPolicesSummary).policies | Where-Object { $_.name -eq "$Policy_Name" })

    ##################################
    # if parameter excel is provided #
    ##################################
    if ($null -ne $PSBoundParameters['excel_path']) {
        # Verify if a specific version of the policy is requested
        switch ($PSCmdlet.ParameterSetName) {
            "ByExcelFileLatestVersion" {
                # Merge cloud policy with excel file with latest version
                $obj_merged_policy = Merge-SepCloudAllowList -Excel $excel_path -Policy_Name $Policy_Name
                $obj_policy = ($obj_policy | Sort-Object -Property policy_version -Descending | Select-Object -First 1)
            }
            "ByExcelFileVersionSpecific" {
                # Merge cloud policy with excel file with specified version
                $obj_merged_policy = Merge-SepCloudAllowList -Excel $excel_path -Policy_Name $Policy_Name -Policy_Version $Policy_Version
                $obj_policy = $obj_policy | Where-Object {
                    $_.name -eq "$Policy_Name" -and $_.policy_version -eq $Policy_Version
                }
            }
            Default {}
        }

        # Setup API query
        $Body = $obj_merged_policy | Optimize-SepCloudAllowListPolicyObject | ConvertTo-Json -Depth 100
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
        $Response = Invoke-RestMethod -Method PATCH -Uri $URI -Headers $Headers -Body $Body -UseBasicParsing

        return $Response
    }
    ##########################################
    # If add or remove parameter is provided #
    ##########################################
    if ($PSBoundParameters['Add'] -or $PSBoundParameters['Remove']) {
        # Verify if a specific version of the policy is requested
        if ($null -ne $PSBoundParameters['Policy_Version']) {
            # Get policy information about the specified version
            $obj_policy = $obj_policy | Where-Object {
                $_.name -eq "$Policy_Name" -and $_.policy_version -eq $Policy_Version
            }
        } else {
            # Get policy information about the latest version
            $obj_policy = ($obj_policy | Sort-Object -Property policy_version -Descending | Select-Object -First 1)
        }

        # Initialize structured obj that will be later converted to JSON
        $obj_body = [UpdateAllowlist]::new()
        if ($PSBoundParameters['Add']) {
            # Add new hash to the obj
            $obj_body.add.AddProcessFile(
                $sha2,
                $file_name
            )
        }
        if ($PSBoundParameters['Remove']) {
            # Add new hash to the obj
            $obj_body.remove.AddProcessFile(
                $sha2,
                $file_name
            )
        }

        # Convert $obj_body from a custom class to a PSCustomObject
        $obj_body = $obj_body | ConvertTo-Json -Depth 100 | ConvertFrom-Json -Depth 100

        # Setup API query
        # Running on body Optimize-SepCloudAllowListPolicyObject to remove empty properties before converting to JSON
        $Body = $obj_body | Optimize-SepCloudAllowListPolicyObject | ConvertTo-Json -Depth 100
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
        $Response = Invoke-RestMethod -Method PATCH -Uri $URI -Headers $Headers -Body $Body -UseBasicParsing

        return $Response
    } else {
        throw "ERROR - No action provided. Use -add or -remove or provide an excel file"
    }
}
