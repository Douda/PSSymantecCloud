function Get-SepCloudIncidents {

    <# TODO fill description for Get-SepCloudIncidents
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


    param (
        # Opened incidents
        [Parameter()]
        [switch]
        $Open,

        # Include events
        [Parameter()]
        [switch]
        $Include_events,

        # Custom query to run
        [Parameter()]
        [string]
        $Query,

        # Max limit of Incidents per query. Max 2000
        [Parameter()]
        [ValidateRange(1, 2000)]
        [int]
        $limit,

        # Query date range Past 30 days
        [Parameter()]
        [switch]
        $Past_30_Days,

        # Query date range Past 7 days
        [Parameter()]
        [switch]
        $Past_7_Days
    )

    # Init
    $BaseURL = (GetConfigurationPath).BaseUrl
    $URI_Tokens = 'https://' + $BaseURL + "/v1/incidents"

    # Get token
    $Token = Get-SEPCloudToken

    if ($null -ne $Token) {
        # HTTP body content containing all the queries
        $Body = @{}

        # Setting dates format
        $obj_end_date = Get-Date -AsUTC
        if ($past_30_Days -eq $true) {
            $obj_start_date = $obj_end_date.AddDays(-30)
        }
        if ($past_7_Days -eq $true) {
            $obj_start_date = $obj_end_date.AddDays(-7)
        }
        $end_date = Get-Date $obj_end_date -UFormat "%Y-%m-%dT%T.000+00:00"
        $start_date = Get-Date $obj_start_date -UFormat "%Y-%m-%dT%T.000+00:00"
        $Body.Add("start_date", $start_date)
        $Body.Add("end_date", $end_date)


        # Iterating through all parameter and adding them to the HTTP body
        if ($Query -ne "") {
            $Body.Add("query", "$Query")
        }
        if ($limit -ne $null) {
            $Body.Add("limit", $limit)
        }
        if ($open -eq $true) {
            $Body.Add("status", "open")
        }
        if ($Include_events -eq $true ) {
            $Body.Add("include_events", "true")
        }
        $Body_Json = ConvertTo-Json $Body

        $Headers = @{
            Host           = $BaseURL
            Accept         = "application/json"
            "Content-Type" = "application/json"
            Authorization  = $Token
        }

        try {
            $Response = Invoke-RestMethod -Method POST -Uri $URI_Tokens -Headers $Headers -Body $Body_Json -UseBasicParsing
            return $Response
        } catch {
            $StatusCode = $_.Exception.Response.StatusCode
            $StatusCode
        }

    }
}
