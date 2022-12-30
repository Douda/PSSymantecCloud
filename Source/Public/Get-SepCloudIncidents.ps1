function Get-SepCloudIncidents {

    <# TODO fill description for Get-SepCloudIncidents
    .SYNOPSIS
        Get list of SEP Cloud incidents. By default, shows opened incidents
    .DESCRIPTION
        Get list of SEP Cloud incidents. Using the LUCENE query syntax, you can customize which incidents to gather. More information : https://techdocs.broadcom.com/us/en/symantec-security-software/endpoint-security-and-management/endpoint-security/sescloud/Endpoint-Detection-and-Response/investigation-page-overview-v134374740-d38e87486/Cloud-Database-Search/query-and-filter-operators-by-data-type-v134689952-d38e88796.html
    .PARAMETER Open
        filters only opened incidents. Simulates a query "state_id: [0 TO 3]" which represents incidents with the following states <0 Unknown | 1 New | 2 In Progress | 3 On Hold>
    .PARAMETER Include_events
        Includes every events that both are part of the context & triggered incident events
    .PARAMETER Query
        Type your customer Lucene query to pass to the API
    .OUTPUTS
        PSObject containing all SEP incidents
    .EXAMPLE
        Get-SepCloudIncidents -Open -Include_Events
    .EXAMPLE
        Get-SepCloudIncidents -Query "state_id: [0 TO 5]"
        This query a list of every possible incidents (opened, closed and with "Unknown" status)
    .LINK
        https://github.com/Douda/PSSymantecCloud
    #>
    [CmdletBinding(DefaultParameterSetName = 'QueryOpen')]
    param (
        # Opened incidents
        [Parameter(
            ParameterSetName = "QueryOpen"
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
        $Query

    )
    begin {
        # Init
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $URI_Tokens = 'https://' + $BaseURL + "/v1/incidents"
        $ArrayResponse = @()
    }

    process {
        # Get token
        $Token = Get-SEPCloudToken

        if ($null -ne $Token) {
            # HTTP body content containing all the queries
            $Body = @{}

            # Settings dates
            $end_date = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffK"
            $start_date = ((Get-Date).addDays(-29)  | Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffK")
            $Body.Add("start_date", $start_date)
            $Body.Add("end_date", $end_date)
            $Body_Json = ConvertTo-Json $Body

            # Iterating through all parameter and adding them to the HTTP body
            switch ($PSBoundParameters.Keys) {
                'Query' {
                    $Body.Add("query", "$Query")
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

            $Headers = @{
                Host           = $BaseURL
                Accept         = "application/json"
                "Content-Type" = "application/json"
                Authorization  = $Token
            }

            try {
                $Response = Invoke-RestMethod -Method POST -Uri $URI_Tokens -Headers $Headers -Body $Body_Json -UseBasicParsing
                $ArrayResponse += $Response
                if ($null -ne $Response.next) {
                    <# If pagination #>
                    do {
                        # change the "next" offset for next query
                        $Body.Remove("next")
                        $Body.Add("next", $Response.next)
                        $Body_Json = ConvertTo-Json $Body
                        # Run query & add it to the array
                        $Response = Invoke-RestMethod -Method POST -Uri $URI_Tokens -Headers $Headers -Body $Body_Json -UseBasicParsing
                        $ArrayResponse += $Response
                    } until (
                        ($null -eq $Response.next)
                    )
                }
            } catch {
                $StatusCode = $_
                $StatusCode
            }
        }
    }
    end {
        return $ArrayResponse.incidents
    }
}
