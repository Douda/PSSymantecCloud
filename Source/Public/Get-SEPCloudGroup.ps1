function Get-SEPCloudGroup {
    <#
    .SYNOPSIS
        Gathers list of device groups from SEP Cloud
    .DESCRIPTION
        Gathers list of device groups from SEP Cloud
    .PARAMETER GroupID
        ID of the group to get details for
    .PARAMETER listDevices
        Switch to get the list of devices in the group
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
        Get-SEPCloudGroup -GroupID "BorQeoSfR5OMJ9R8SumJNw" -listDevices

        total devices
        ----- -------
        2341 {@{id=-143bW_uRyyToCarc-AN0x; name=DESKTOP-ABCD}, @{id=-1djir6BSfib3sFDD1NVFw; name=DESKTOP-EFGH}...
    #>

    [CmdletBinding(DefaultParameterSetName = 'DefaultSet')]
    param (
        # Group ID
        [Parameter(
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'DeviceListSet'
        )]
        [String]
        $GroupID,

        # List devices switch
        [Parameter(
            ParameterSetName = 'DeviceListSet'
        )]
        [switch]
        $listDevices
    )

        # Setting up the URI
        $URI = 'https://' + $script:SEPCloudConnection.BaseURL + "/v1/device-groups"
        if ($GroupID) {
            $URI = $URI + "/$GroupID"

            if ($listDevices) {
                $URI = $URI + "/devices"
            }
        }

        # Setting up the parameters
        $params = @{
            Method  = 'GET'
            Uri     = $uri
            Headers = @{
                # Host          = $baseUrl
                Accept        = "application/json"
                Authorization = $script:SEPCloudConnection.accessToken.Token_Bearer
            }
        }

        # Invoke the request
        try {
            $response = Invoke-SEPCloudWebRequest @params

            # if $response is null, return an empty object to avoid further errors
            if ($null -eq $response) {
                return [PSCustomObject]@{}
            }
        } catch {
            "Error : " + $_
        }

        ########################
        # Parsing the response #
        ########################

        # if ListDevices is set, we get a list of devices
        if ($listDevices) {
            # If we get a list of devices
            # Add Device-List PSTypeName to the response
            $response | ForEach-Object {
                $_.PSTypeNames.Insert(0, "SEPCloud.Device-List")
            }

            # Add Device PSTypeName to the devices
            $response.devices | ForEach-Object {
                $_.PSTypeNames.Insert(0, "SEPCloud.Device")
            }
        }

        # If groupID is set, we get a single group
        elseif ($GroupID) {
            # Add a new property with the full chain of names
            $groups = (Get-SEPCloudGroup).device_groups
            $FullNameChain = Get-NameChain -CurrentGroup $response -AllGroups $groups -Chain ""
            $response | Add-Member -NotePropertyName "fullPathName" -NotePropertyValue $FullNameChain.TrimEnd(" > ")

            # Add PSTypeName to the response
            $response.PSTypeNames.Insert(0, "SEPCloud.Device-Group")

            # If nothing is set, we get a list of groups
        } else {
            # Add a new property to each group with the full path name (group)
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
