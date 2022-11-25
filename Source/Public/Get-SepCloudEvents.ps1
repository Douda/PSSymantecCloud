function Get-SepCloudEvents {
    <# TODO fill description for Get-SepCloudEvents
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
        # file Detection
        [Parameter()]
        [switch]
        $FileDetection,

        # Custom query to run
        [Parameter()]
        [string]
        $Query
    )

    begin {
        # Init
        $BaseURL = (GetConfigurationPath).BaseUrl
        $URI_Tokens = 'https://' + $BaseURL + "/v1/event-search"

        # Pagination init
        $ArrayResponse = @()
    }

    process {
        # Get token
        $Token = Get-SEPCloudToken

        if ($null -ne $Token) {
            # HTTP body content containing all the queries
            $Body = @{
                "product"      = "SAEP"
                "feature_name" = "ALL"
            }
            <#
        Setting dates for the query Date Format required : -UFormat "%Y-%m-%dT%T.000+00:00"
        Example :
        "start_date": "2022-10-16T00:00:00.000+00:00",
        "end_date": "2022-11-16T00:00:00.000+00:00"
        #>

            $end_date = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffK"
            $start_date = ((Get-Date).addDays(-30) | Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffK")
            $Body.Add("start_date", $start_date)
            $Body.Add("end_date", $end_date)

            # Iterating through all parameter and adding them to the HTTP body
            switch ($PSBoundParameters.Keys) {
                'FileDetection' {
                    $Body.Add("query", '( feature_name:MALWARE_PROTECTION AND ( type_id:8031 OR type_id:8032 OR type_id:8033 OR type_id:8027 OR type_id:8028 ) AND ( id:12 OR id:11 AND type_id:8031 ) )')
                }
                'Query' {
                    $Body.Add("query", "$Query")
                }
                Default {
                }
            }

            # Setting up pagination
            $next = 0
            $limit = 100
            $Body.Add("limit", $limit)
            $Body_Json = ConvertTo-Json $Body

            $Headers = @{
                Host           = $BaseURL
                Accept         = "application/json"
                "Content-Type" = "application/json"
                Authorization  = $Token
            }

            try {
                do {
                    $Response = Invoke-RestMethod -Method POST -Uri $URI_Tokens -Headers $Headers -Body $Body_Json -UseBasicParsing
                    $ArrayResponse += $Response
                    $Body.Remove("next")
                    $Body.Add("next", $next + $limit)
                    $Body_Json = ConvertTo-Json $Body
                    # Testing while loop
                    # $compare_events = ($arrayresponse.events | Measure-Object | Select-Object -ExpandProperty Count)
                    # $compare_next = ($arrayresponse[0].Total)
                } while (
                    <# Compare scraped events vs total from 1st API query #>
                ($arrayresponse.events | Measure-Object | Select-Object -ExpandProperty Count) -lt ($arrayresponse[0].Total)
                )
            } catch {
                $StatusCode = $_.Exception.Response.StatusCode
                $StatusCode
            }
        }
    }

    end {
        return $ArrayResponse
    }
}
