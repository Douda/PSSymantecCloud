function Get-SepCloudEventSearch {
    <# TODO fill description for Get-SepCloudEventSearch
    .SYNOPSIS
        Get list of SEP Cloud Events. By default, every events for the past 30 days
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .PARAMETER FileDetection
        Runs the following query under the hood "feature_name:MALWARE_PROTECTION AND ( type_id:8031 OR type_id:8032 OR type_id:8033 OR type_id:8027 OR type_id:8028 ) AND ( id:12 OR id:11 AND type_id:8031 )"
    .LINK
        https://github.com/Douda/PSSymantecCloud
    .EXAMPLE
        Get-SepCloudEventSearch -FileDetection
    .EXAMPLE
        Get-SepCloudEventSearch - Query "type_id:8031 OR type_id:8032 OR type_id:8033"
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
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $URI_Tokens = 'https://' + $BaseURL + "/v1/event-search"
        $ArrayResponse = @()
    }

    process {
        # Get token
        $Token = Get-SEPCloudToken

        if ($null -ne $Token) {
            # HTTP body content containing all mandatory info to start a query
            $Body = @{
                "product"      = "SAEP"
                "feature_name" = "ALL"
            }
            <# Setting dates for the query Date Format required : -UFormat "%Y-%m-%dT%T.000+00:00"
            Example :
            "start_date": "2022-10-16T00:00:00.000+00:00",
            "end_date": "2022-11-16T00:00:00.000+00:00" #>

            $end_date = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffK"
            $start_date = ((Get-Date).addDays(-29) | Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffK")
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

            # Convert body to Json after adding potential query with parameters
            $Body_Json = ConvertTo-Json $Body

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
        return $ArrayResponse.events
    }
}
