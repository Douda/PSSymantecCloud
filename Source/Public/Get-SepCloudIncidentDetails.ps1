function Get-SepCloudIncidentDetails {

    <# TODO fill description
    TODO finish up the API query from incident_number and not UID for ease of use
.SYNOPSIS
    A short one-line action-based description, e.g. 'Tests if a function is valid'
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
.NOTES
    Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>
    [CmdletBinding()]
    param (
        # Incident GUID
        [Parameter(
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        [Alias("incident_uid")]
        $Incident_ID,

        # Incident number
        [Parameter(
            ValueFromPipeline
        )]
        [string[]]
        [Alias("Name")]
        $Incident_number
    )

    begin {
        # Init
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $Token = Get-SEPCloudToken
        #$obj_incidents = Get-SepCloudIncidents
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
