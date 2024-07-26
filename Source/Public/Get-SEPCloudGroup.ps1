function Get-SEPCloudGroup {
    <#
    .SYNOPSIS
        Gathers list of device groups from SEP Cloud
    .DESCRIPTION
        Gathers list of device groups from SEP Cloud
    .PARAMETER GroupID
        ID of the group to get details for
    .EXAMPLE
        Get-SEPCloudGroup -GroupID "BorQeoSfR5OMJ9R8SumJNw"

        id           : BorQeoSfR5OMJ9R8SumJNw
        name         : Workstations
        description  : Description of this group
        created      : 16/02/2024 09:04:33
        modified     : 16/02/2024 09:04:33
        parent_id    : tqrSman3RyqFFd1EqLlZZA
        fullPathName : Default\Test policies tests\subgroup 1
    .EXAMPLE
        Get-SEPCloudGroup -GroupID "BorQeoSfR5OMJ9R8SumJNw"

        total devices
        ----- -------
        2341 {@{id=-143bW_uRyyToCarc-AN0x; name=DESKTOP-ABCD}, @{id=-1djir6BSfib3sFDD1NVFw; name=DESKTOP-EFGH}...
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
        # Setting up the URI
        if ($GroupID) {
            $URI = $URI + "/$GroupID"
        }

        $allResponse = [PSCustomObject]@{}
        do {
            try {
                # Setting up the parameters
                $params = @{
                    Method  = 'GET'
                    Uri     = $uri
                    Headers = @{
                        # Host          = $baseUrl
                        Accept        = "application/json"
                        Authorization = $token
                    }
                }

                # Invoke the request
                $response = Invoke-ABWebRequest @params

                # Process the response
                # Setting up pagination
                if ($queryStrings) {
                    # Other pass
                    $allResponse.device_groups += $response.device_groups
                } else {
                    # First pass
                    $allResponse = $response
                }

                # Setup pagination only for full group list and not for a single group
                if (!$GroupID) {
                    # QueryString parameters for pagination
                    $queryStrings = @{
                        offset = $allResponse.device_groups.count
                    }
                    # Increment the offset if necessary
                    $uri = Build-QueryURI -BaseURI $uri -QueryStrings $queryStrings
                }

            } catch {
                Write-Warning -Message "Error: $_"
            }
        } until (
            $allResponse.device_groups.count -ge $response.total
        )



        ########################
        # Parsing the response #
        ########################

        # If groupID is set, we get a single group
        if ($GroupID) {
            # Add a new property with the full chain of names
            $FullNameChain = Get-SEPCloudGroupFullPath -CurrentGroup $response -Chain ""
            $allResponse | Add-Member -NotePropertyName "fullPathName" -NotePropertyValue $FullNameChain.TrimEnd(" > ")

            # Add PSTypeName to the response
            $allResponse.PSTypeNames.Insert(0, "SEPCloud.Device-Group")

            # If nothing is set, we get a list of groups
        } else {
            # Add a new property to each group with the full path name (group)
            $allResponse.device_groups | ForEach-Object {
                $FullNameChain = Get-SEPCloudGroupFullPath -CurrentGroup $_ -AllGroups $allResponse.device_groups -Chain ""
                $_ | Add-Member -NotePropertyName "fullPathName" -NotePropertyValue $FullNameChain.TrimEnd(" > ")
            }

            # Add PSTypeName to the response
            $allResponse.device_groups | ForEach-Object {
                $_.PSTypeNames.Insert(0, "SEPCloud.Device-Group")
            }
        }

        # Return the response
        return $allResponse
    }
}
