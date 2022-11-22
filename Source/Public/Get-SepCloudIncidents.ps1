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
        $Include_events
    )

    # Init
    $BaseURL = (GetConfigurationPath).BaseUrl
    $URI_Tokens = 'https://' + $BaseURL + "/v1/incidents"

    # Get token
    $Token = Get-SEPCloudToken

    if ($null -ne $Token) {
        # HTTP body content containing all the queries
        $Body = @{}
        # Iterating through all parameter and adding them to the HTTP body
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