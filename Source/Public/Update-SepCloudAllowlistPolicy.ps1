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
        GUID of the policy. Optional. The function can gathers the GUID from the policy name
    .PARAMETER Policy_Version
        Version of the policy to update
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
        [Alias("Name")]
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
        # Get list of all SEP Cloud policies, gather only the one based on name
        $obj_policies = (Get-SepCloudPolices).policies
        $obj_policy = ($obj_policies | Where-Object { $_.name -eq "$Policy_Name" })

        # If policy name doesn't exist, error
        if (($null -or "") -eq $obj_policy ) {
            Write-Error "Policy not found - Please verify policy name"
            break
        }

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
        $URI = 'https://' + $BaseURL + "/v1/policies/allow-list/$Policy_UUID/versions/$Policy_Version"
        # Get token
        $Token = Get-SEPCloudToken

        # TODO setup $body with JSON based content to add allow list content
        # Getting started with Classes
        # https://stackoverflow.com/questions/74827989/create-the-skeleton-of-a-custom-psobject-from-scratch/74828486#74828486
        class addjson {
            [object] $add

            addjson() {
                $this.add = [pscustomobject]@{
                    applications = [System.Collections.Generic.List[object]]::new()
                }
            }

            # method to add processfile sha2 & name to the main obj
            [void] AddProcessFile([string] $sha2, [string] $name) {
                $this.add.applications.Add([pscustomobject]@{
                        processfile = [pscustomobject]@{
                            sha2 = $sha2
                            name = $name
                        }
                    })
            }
        }

        # Importing Excel list
        # TODO finish main Object creation to pass to API as body
        # Testing $ExcelFile for troubleshoot
        $ExcelFile = ".\Data\test.xlsx"
        $application = Import-Excel -Path "$ExcelFile" -WorksheetName Applications

        # Creating my main object as an instance of addjson class
        $obj_body = [addjson]::new()

        # Parsing Excel list and add content to obj
        foreach ($hash in $application) {
            $obj_body.AddProcessFile($hash.sha2, $hash.name)
        }

        # Converting PSObj to json
        # $Body = @{}
        $Body = $obj_body | ConvertTo-Json -Depth 5


        if ($null -ne $Token) {
            # $Body = @{}
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
