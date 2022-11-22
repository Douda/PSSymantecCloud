function Get-SepCloudEvents {
    param (
        # file Detection
        [Parameter()]
        [switch]
        $FileDetection,

        # Custom query to run
        [Parameter()]
        [string]
        $Query,

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
    $URI_Tokens = 'https://' + $BaseURL + "/v1/event-search"

    # Get token
    $Token = Get-SEPCloudToken

    if ($null -ne $Token) {
        # HTTP body content containing all the queries
        $Body = @{
            "product"      = "SAEP"
            "feature_name" = "ALL"
        }
        <#
        Setting dates for the query
        Date Format required : -UFormat "%Y-%m-%dT%T.000+00:00" 
        Example : 
        "start_date": "2022-10-16T00:00:00.000+00:00",
        "end_date": "2022-11-16T00:00:00.000+00:00"
        Set correct date formats to query the past 30 days
        End date = today
        Start date = X days ago (30 days maximum)
        #>
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
        if ($FileDetection -eq $true) {
            # Testing hardcoded query (file detection)
            $Body.Add("query", '( feature_name:MALWARE_PROTECTION AND ( type_id:8031 OR type_id:8032 OR type_id:8033 OR type_id:8027 OR type_id:8028 ) AND ( id:12 OR id:11 AND type_id:8031 ) )')
        }

        if ($Query -ne "") {
            $Body.Add("query", "$Query")
        }


        $Body_Json = ConvertTo-Json $Body

        $Headers = @{
            Host           = $BaseURL
            Accept         = "application/json"
            "Content-Type" = "application/json"
            Authorization  = $Token
        }

        try {
            $Response = Invoke-RestMethod -Method POST -FollowRelLink -Uri $URI_Tokens -Headers $Headers -Body $Body_Json -UseBasicParsing 
            return $Response
        } catch {
            $StatusCode = $_.Exception.Response.StatusCode
            $StatusCode
        }
    }
}