function Get-SepCloudIncidents {

    <#
    .SYNOPSIS
        Get list of SEP Cloud incidents. By default, shows only opened incidents
    .DESCRIPTION
        Get list of SEP Cloud incidents. Using the LUCENE query syntax, you can customize which incidents to gather.
        More information : https://techdocs.broadcom.com/us/en/symantec-security-software/endpoint-security-and-management/endpoint-security/sescloud/Endpoint-Detection-and-Response/investigation-page-overview-v134374740-d38e87486/Cloud-Database-Search/query-and-filter-operators-by-data-type-v134689952-d38e88796.html
    .PARAMETER Open
        filters only opened incidents. Simulates a query "state_id: [0 TO 3]" which represents incidents with the following states <0 Unknown | 1 New | 2 In Progress | 3 On Hold>
    .PARAMETER Include_events
        Includes every events that both are part of the context & triggered incident events
    .PARAMETER Query
        Custom Lucene query to pass to the API
    .INPUTS
        None
    .OUTPUTS
        PSObject containing all SEP incidents
    .EXAMPLE
        Get-SepCloudIncidents -Open -Include_Events
    .EXAMPLE
        Get-SepCloudIncidents -Query "state_id: [0 TO 5]"
        This query a list of every possible incidents (opened, closed and with "Unknown" status)
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
        $BaseURL = $($script:configuration.BaseURL)
        $URI_Tokens = 'https://' + $BaseURL + "/v1/incidents"
        $ArrayResponse = @()
        $Token = (Get-SEPCloudToken).Token_Bearer
    }

    process {

        # HTTP body content containing all the queries
        $Body = @{}

        # Settings dates
        $end_date = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffK"
        $start_date = ((Get-Date).addDays(-29) | Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffK")
        $Body.Add("start_date", $start_date)
        $Body.Add("end_date", $end_date)

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
            do {
                $params = @{
                    Uri             = $URI_Tokens
                    Method          = 'POST'
                    Body            = $Body | ConvertTo-Json
                    Headers         = $Headers
                    UseBasicParsing = $true
                }

                $Response = Invoke-RestMethod @params
                $ArrayResponse += $Response
                $Body.Remove("next")
                $Body.Add("next", $Response.next)
            } until ($null -eq $Response.next)
        } catch {
                Write-Warning -Message "Error: $_"
            }

        return $ArrayResponse.incidents
    }
}
