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
            $URI = $URI + "/$GroupID"
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
            $response = Invoke-ABWebRequest @params
        } catch {
            "Error : " + $_
        }

        if ($GroupID) {
            # If we get a single group

            # Add a new property with the full chain of names
            $groups = (Get-SEPCloudGroup).device_groups
            $FullNameChain = Get-NameChain -CurrentGroup $response -AllGroups $groups -Chain ""
            $response | Add-Member -NotePropertyName "fullPathName" -NotePropertyValue $FullNameChain.TrimEnd(" > ")

            # Add PSTypeName to the response
            $response.PSTypeNames.Insert(0, "SEPCloud.Device-Group")
        } else {
            # Else we get a list of groups

            # Add a new property to each group with the full chain of names
            $response.device_groups | ForEach-Object {
                $FullNameChain = Get-NameChain -CurrentGroup $_ -AllGroups $groups.device_groups -Chain ""
                $_ | Add-Member -NotePropertyName "fullPathName" -NotePropertyValue $FullNameChain.TrimEnd(" > ")
            }

            # Add PSTypeName to the response
            $response.device_groups | ForEach-Object {
                $_.PSTypeNames.Insert(0, "SEPCloud.Device-Group")
            }
        }

        # Return the response
        return $response
    }
}
