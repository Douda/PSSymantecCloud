function Get-SepCloudIncidentDetails {

    <# TODO fill description
    TODO finish up the API query from incident_number and not UID for ease of use
.SYNOPSIS
    Gathers details about an open incident
.DESCRIPTION
    Gathers details about an open incident. Currently only supports gathering details from an incident UID
.PARAMETER incident_uid
    Incident GUID
.PARAMETER incident_number
    Incident number -- NOT IMPLEMENTED YET --
.EXAMPLE
    Get-SepCloudIncidentDetails -incident_uid "ed5924c6-b36d-4449-88c1-4a1f974a01bb"
#>
    [CmdletBinding()]
    param (
        # Incident GUID
        [Parameter(
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        [Alias("incident_uid")]
        $Incident_ID

        # # Incident number
        # [Parameter(
        #     ValueFromPipeline
        # )]
        # [string[]]
        # [Alias("Name")]
        # $Incident_number
    )

    begin {
        # Init
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $Token = (Get-SEPCloudToken).Token_Bearer
    }

    process {
        $URI = 'https://' + $BaseURL + "/v1/incidents/$Incident_ID"

        $Body = @{}
        $Headers = @{
            Host          = $BaseURL
            Accept        = "application/json"
            Authorization = $Token
            Body          = $Body
        }
        $Resp = Invoke-RestMethod -Method GET -Uri $URI -Headers $Headers -Body $Body -UseBasicParsing

        $Resp
    }
}
