function Get-SepCloudEventSearch {
    <#
    .SYNOPSIS
        Get list of SEP Cloud Events. By default it will gather data for past 30 days
    .DESCRIPTION
        Get list of SEP Cloud Events. You can use the following parameters to filter the results: FileDetection, FullScan, or a custom Lucene query
    .INPUTS
        [string] Query
        [int] PastDays
        [switch] FileDetection
        [switch] FullScan
    .OUTPUTS
        [PSCustomObject] Events
    .PARAMETER Query
        Runs a custom Lucene query
    .PARAMETER PastDays
        Number of days to go back in the past. Default is 29 days
    .PARAMETER FullScan
        Runs the following Lucene query "Event Type Id:8020-Scan AND Scan Name:Full Scan"
    .PARAMETER FileDetection
        Runs the following Lucene query "feature_name:MALWARE_PROTECTION AND ( type_id:8031 OR type_id:8032 OR type_id:8033 OR type_id:8027 OR type_id:8028 ) AND ( id:12 OR id:11 AND type_id:8031 )"
    .EXAMPLE
        Get-SepCloudEventSearch
        Gather all possible events. ** very slow approach & limited to 10k events **
    .EXAMPLE
        Get-SepCloudEventSearch -FileDetection -pastdays 20
        Gather all file detection events for the past 20 days
    .EXAMPLE
        Get-SepCloudEventSearch -FullScan
        Gather all full scan events
    .EXAMPLE
        Get-SepCloudEventSearch -Query "type_id:8031 OR type_id:8032 OR type_id:8033"
        Runs a custom Lucene query
    .EXAMPLE
        Get-SepCloudEventSearch -Query "type_id:8031 OR type_id:8032 OR type_id:8033" -PastDays 14
        Runs a custom Lucene query for the past 14 days
    #>
    [CmdletBinding(DefaultParameterSetName = 'Query')]
    param (
        # file Detection
        [Parameter(ParameterSetName = 'FileDetection')]
        [switch]
        $FileDetection,

        # full scan
        [Parameter(ParameterSetName = 'FullScan')]
        [switch]
        $FullScan,

        # Custom query to run
        [Parameter(ParameterSetName = 'Query')]
        [string]
        $Query,

        # Date parameter
        [Parameter()]
        [Alias("Days")]
        [int]
        $PastDays = 29
    )

    begin {
        # Init
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $URI_Tokens = 'https://' + $BaseURL + "/v1/event-search"
        $ArrayResponse = @()
        $Token = (Get-SEPCloudToken).Token_Bearer
    }

    process {

        # HTTP body content containing all mandatory info to start a query
        $Body = @{
            "product"      = "SAEP"
            "feature_name" = "ALL"
        }
        <# Setting dates for the query Date Format required : -UFormat "%Y-%m-%dT%T.000+00:00"
        Example :
        "start_date": "2022-10-16T00:00:00.000+00:00",
        "end_date": "2022-11-16T00:00:00.000+00:00" #>

        # Setting dates for the query Date Format required : -UFormat "%Y-%m-%dT%T.000+00:00"
        $end_date = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffK")
        $start_date = ((Get-Date).AddDays(-$PastDays) | Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffK")
        $Body.Add("start_date", $start_date)
        $Body.Add("end_date", $end_date)

        # Iterating through all parameter and adding them to the HTTP body
        switch ($PSBoundParameters.Keys) {
            'FileDetection' {
                $Body.Add("query", '( feature_name:MALWARE_PROTECTION AND ( type_id:8031 OR type_id:8032 OR type_id:8033 OR type_id:8027 OR type_id:8028 ) AND ( id:12 OR id:11 AND type_id:8031 ) )')
            }
            'FullScan' {
                $Body.Add("query", 'Event Type Id:8020-Scan AND Scan Name:Full Scan')
            }
            'Query' {
                $Body.Add("query", "$Query")
            }
            Default {}
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

            while ($Response.next) {
                # change the "next" offset for pagination
                $Body.Remove("next")
                $Body.Add("next", $Response.next)
                $Body_Json = ConvertTo-Json $Body

                # Run query & add it to the array
                $Response = Invoke-RestMethod -Method POST -Uri $URI_Tokens -Headers $Headers -Body $Body_Json -UseBasicParsing
                $ArrayResponse += $Response
            }
        } catch {
            $StatusCode = $_
            $StatusCode
        }

        return $ArrayResponse.events
    }
}
