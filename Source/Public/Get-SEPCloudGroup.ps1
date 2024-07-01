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
        if ($GroupID) {
            $URI = $URI + '/' + $GroupID
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

        return $response
    }
}
