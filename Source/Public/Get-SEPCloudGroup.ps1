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

        id          : BorQeoSfR5OMJ9R8SumJNw
        name        : Workstations
        description :
        created     : 16/02/2024 09:04:33
        modified    : 16/02/2024 09:04:33
        parent_id   : tqrSman3RyqFFd1EqLlZZA
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
