function Get-SepCloudFeatureList {
    <# TODO : fill in description Get-SepCloudFeatureList
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
    )
    
    # Init
    $BaseURL = (GetConfigurationPath).BaseUrl
    $URI_Tokens = 'https://' + $BaseURL + "/v1/devices/enums"
    # Get token
    $Token = Get-SEPCloudToken  

    if ($null -ne $Token) {
        # HTTP body content containing all the queries
        $Body = @{}
        $Headers = @{
            Host          = $BaseURL
            Accept        = "application/json"
            Authorization = $Token
            Body          = $Body
        }
        $Response = Invoke-RestMethod -Method GET -Uri $URI_Tokens -Headers $Headers -Body $Body -UseBasicParsing 
        return $Response
    }
}