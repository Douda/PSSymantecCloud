function Update-SepCloudAllowlistPolicy {
    <#
    .SYNOPSIS
        Updates Symantec Allow List policy using an excel file
    .DESCRIPTION
        Gathers Allow List policy information from an Excel file generated from Export-SepCloudPolicyToExcel function
                You can manually add lines to the Excel file, and the updated file will be used to add new exceptions to the Allow list policy of your choice
    .INPUTS
        Excel file generated from Export-SepCloudPolicyToExcel function
        Policy name to update
        OPTIONAL : policy version (default latest version)
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
            ValueFromPipeline,
            Mandatory
        )]
        [string]
        [Alias("PolicyName")]
        $Policy_Name,

        # Excel file to import data from
        [Parameter()]
        [string]
        [Alias("Excel")]
        $ExcelFile
    )

    begin {
        # Init
        $BaseURL = (GetConfigurationPath).BaseUrl
    }

    process {
        # Get list of all SEP Cloud policies, gather only the one based on name (gets every version of the same name)
        $obj_policies = (Get-SepCloudPolices).policies
        $obj_policy_info = ($obj_policies | Where-Object { $_.name -eq "$Policy_Name" })

        # If policy name doesn't exist, error
        if (($null -or "") -eq $obj_policy_info ) {
            Write-Error "Policy not found - Please verify policy name"
            break
        }

        # Use specific version or by default latest
        if ($Policy_version -ne "") {
            $obj_policy_info = $obj_policy_info | Where-Object {
                $_.name -eq "$Policy_Name" -and $_.policy_version -eq $Policy_Version
            }
        } else {
            $obj_policy_info = ($obj_policy_info | Sort-Object -Property policy_version -Descending | Select-Object -First 1)
        }

        # Set UUID & version from policy & URI
        $Policy_UUID = ($obj_policy_info).policy_uid
        $Policy_Version = ($obj_policy_info).policy_version
        $URI = 'https://' + $BaseURL + "/v1/policies/allow-list/$Policy_UUID/versions/$Policy_Version"
        # Get token
        $Token = Get-SEPCloudToken

        # TODO setup $body with JSON based content to add allow list content
        # Getting started with Classes
        # https://stackoverflow.com/questions/74827989/create-the-skeleton-of-a-custom-psobject-from-scratch/74828486#74828486


        # Importing Excel list
        # TODO finish main Object creation to pass to API as body
        # Testing $ExcelFile for troubleshoot/dev
        # TODO remove $ExcelFile hardcoded path once obj is complete
        $ExcelFile = ".\Data\Workstations_allowlist.xlsx"
        $application = Import-Excel -Path "$ExcelFile" -WorksheetName Applications
        $files = Import-Excel -Path "$ExcelFile" -WorksheetName Files

        # Creating my main object as an instance of addjson class
        $obj_body = [addjson]::new()

        ######################
        # Parsing Excel list #
        ######################
        # Add APPLICATIONS excel tab to obj
        foreach ($a in $application) {
            $obj_body.AddProcessFile($a.sha2, $a.name)
        }

        # Add FILES excel tab to obj
        foreach ($f in $files) {
            # Gather list of features properties & resetting $features array counter
            [array]$features = @()
            [array]$FeatureNumbers = $f.PSObject.properties.name | Select-String -Pattern feature
            # ForEach property, get the property value and store it in $features
            foreach ($feat in $FeatureNumbers) {
                $features += $f.$feat
            }
            $obj_body.AddWindowsFiles(
                $f.pathvariable,
                $f.path,
                $f.scheduled,
                $features
            )
        }

        # At this stage $obj_body contains the full import of excel allow list files/directories etc..
        # Now we need to compare this obj_body to the policy we'll update to remove duplicates
        # TODO : create a merge function (Merge-SepCloudPolicyAndExcelReport)


        # Converting PSObj to json
        $Body = $obj_body | ConvertTo-Json -Depth 10

        # API query
        if ($null -ne $Token) {
            $Headers = @{
                Host           = $BaseURL
                "Content-Type" = "application/json"
                Accept         = "application/json"
                Authorization  = $Token
            }
            $Response = Invoke-RestMethod -Method PATCH -Uri $URI -Headers $Headers -Body $Body -UseBasicParsing
        } else {
            Write-Error "Invalid or empty token - exit"
            break
        }
    }

    end {
        return $Response
    }

}
