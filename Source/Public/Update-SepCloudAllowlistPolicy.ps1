function Update-SepCloudAllowlistPolicy {
    <#
    .SYNOPSIS
        Updates Symantec Allow List policy using an excel file
    .DESCRIPTION
        Gathers Allow List policy information from an Excel file generated from Export-SepCloudPolicyToExcel function
        creates
    .INPUTS
        path of
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>


    # TODO to finish; test cmd-let
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
            <# Action to perform if the condition is true #>
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
        $URI = 'https://' + $BaseURL + "/v1/policies/$Policy_UUID/versions/$Policy_Version"
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
        # TODO remove hardcoded excel path
        # TODO finish main Object creation to pass to API as body
        $application = Import-Excel -Path .\Data\test.xlsx -WorksheetName Applications

        # Creating my main object as an instance of addjson class
        $obj_body = [addjson]::new()

        # Parsing Excel list and add content to obj
        foreach ($hash in $application) {
            $obj_body.AddProcessFile($hash.sha2, $hash.name)
        }
        $obj_body


        if ($null -ne $Token) {
            $Body = @{}
            $Headers = @{
                Host          = $BaseURL
                Accept        = "application/json"
                Authorization = $Token
                Body          = $Body
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
