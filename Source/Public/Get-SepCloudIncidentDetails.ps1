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
            Mandatory,
            ValueFromPipeline
        )]
        [string[]]
        [Alias("Name")]
        $Incident_number
    )

    begin {
        # Init
        $Token = Get-SEPCloudToken
        # Get list of all SEP Cloud policies
        $obj_policies = (Get-SepCloudPolices).policies
    }

    process {
        # Filter only the policy with the correct name
        $obj_policy = ($obj_policies | Where-Object { $_.name -eq "$Policy_Name" })

        $Policy_UUID = ($obj_policy).policy_uid
        $Policy_Version = ($obj_policy).policy_version
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $URI = 'https://' + $BaseURL + "/v1/policies/$Policy_UUID/versions/$Policy_Version"

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
