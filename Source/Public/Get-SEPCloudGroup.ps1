function Get-SEPCloudGroup {
    <# TODO update help
    .SYNOPSIS
    Gathers list of device groups from SEP Cloud
    .DESCRIPTION
    Gathers list of device groups from SEP Cloud
    .PARAMETER
    None
    .EXAMPLE
    Get-SEPCloudGroup

        id          : BorQeoSfR5OMJ9R8SumJNw
        name        : Workstations
        description :
        created     : 16/02/2024 09:04:33
        modified    : 16/02/2024 09:04:33
        parent_id   : tqrSman3RyqFFd1EqLlZZA

        id        : tqrSman3RyqFFd1EqLlZZA
        name      : Default
        created   : 10/01/2024 17:42:02
        modified  : 10/01/2024 17:42:02
        parent_id :
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
        # Setup Headers
        $Headers = @{
            Host          = $BaseURL
            Accept        = "application/json"
            Authorization = $Token
        }

        if ($GroupID) {
            $URI = $URI + '/' + $GroupID
        }

        try {
            $params = @{
                Uri     = $URI
                Method  = 'GET'
                Body    = $Body
                Headers = $Headers
            }

            $Response = Invoke-RestMethod @params

        } catch {
            # If error, return the status code
            $_
        }

        # Add a PSTypeName to the object
        $Response.device_groups | ForEach-Object {
            $_.PSTypeNames.Insert(0, "SEPCloud.Device-Group")
        }

        return $Response.device_groups
    }
}
