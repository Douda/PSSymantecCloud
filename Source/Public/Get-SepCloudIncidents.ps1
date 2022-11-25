function Get-SepCloudIncidents {

    <# TODO fill description for Get-SepCloudIncidents
    .SYNOPSIS
        Get list of SEP Cloud incidents
    .DESCRIPTION
        Get list of SEP Cloud incidents. Using the LUCENE query syntax, you can customize which incidents to gather. More information : https://techdocs.broadcom.com/us/en/symantec-security-software/endpoint-security-and-management/endpoint-security/sescloud/Endpoint-Detection-and-Response/investigation-page-overview-v134374740-d38e87486/Cloud-Database-Search/query-and-filter-operators-by-data-type-v134689952-d38e88796.html
    .PARAMETER Open
        filters only opened incidents. Simulates a query "state_id: [0 TO 3]" which represents incidents with the following states <0 Unknown | 1 New | 2 In Progress | 3 On Hold>
    .PARAMETER Include_events
        Includes every events that both are part of the context & triggered incident events
    .PARAMETER Query
        Type your customer Lucene query to pass to the API
    .PARAMETER limit
        Limit of incidents returned by query. max 2000 which is the default
    .OUTPUTS
        PSObject containing all SEP incidents
    .EXAMPLE
        Get-SepCloudIncidents -Open -Include_Events
    .EXAMPLE
        Get-SepCloudIncidents -Query "state_id: [0 TO 5]"
        This query a list of every possible incidents (opened, closed and with "Unknown" status)
    #>

    param (
        # Opened incidents
        [Parameter(
            ParameterSetName = "QueryDate"
        )]
        [switch]
        $Open,

        # Include events
        [Parameter()]
        [switch]
        $Include_events,

        # Custom query to run
        [Parameter(
            ParameterSetName = "QueryCustom"
        )]
        [string]
        $Query,

        # Max limit of Incidents per query. Max 2000
        [Parameter()]
        [ValidateRange(1, 2000)]
        [int]
        $limit = 2000
    )

    # Init
    $BaseURL = (GetConfigurationPath).BaseUrl
    $URI_Tokens = 'https://' + $BaseURL + "/v1/incidents"

    # Get token
    $Token = Get-SEPCloudToken

    if ($null -ne $Token) {
        # HTTP body content containing all the queries
        $Body = @{}

        # Settings dates
        $obj_end_date = Get-Date -AsUTC
        $obj_start_date = $obj_end_date.AddDays(-29)
        $end_date = Get-Date $obj_end_date -UFormat "%Y-%m-%dT%T.000+00:00"
        $start_date = Get-Date $obj_start_date -UFormat "%Y-%m-%dT%T.000+00:00"
        $Body.Add("start_date", $start_date)
        $Body.Add("end_date", $end_date)

        # Iterating through all parameter and adding them to the HTTP body
        switch ($PSBoundParameters.Keys) {
            'Query' {
                $Body.Add("query", "$Query")
            }
            'limit' {
                $Body.Add("limit", $limit)
            }
            'Open' {
                $Body.Add("query", "state_id: [0 TO 3]")
            }
            'Include_events' {
                $Body.Add("include_events", "true")
            }
            Default {
            }
        }
        $Body_Json = ConvertTo-Json $Body

        $Headers = @{
            Host           = $BaseURL
            Accept         = "application/json"
            "Content-Type" = "application/json"
            Authorization  = $Token
        }
        # TODO add pagination like with Get-SepCloudEvents
        try {
            $Response = Invoke-RestMethod -Method POST -Uri $URI_Tokens -Headers $Headers -Body $Body_Json -UseBasicParsing
            return $Response
        } catch {
            $StatusCode = $_.Exception.Response.StatusCode
            $StatusCode
        }

    }
}
