function Get-SEPCloudComponent {

    <#
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

    [CmdletBinding()]
    param (
        # Component Type is one of the list
        [Parameter(
            Mandatory = $true
        )]
        [ValidateSet(
            'network-ips',
            'host-groups',
            'network-adapters',
            'network-services'
        )]
        [string]
        $ComponentType,

        # ComponentUID
        [Parameter()]
        [string]
        $ComponentUID
    )

    begin {
        # Init
        $BaseURL = $($script:configuration.BaseURL)
        $URI = 'https://' + $BaseURL + "/v1/policies/components"
        $Token = (Get-SEPCloudToken).Token_Bearer
    }

    process {
        $allResults = @()
        $URI = $URI + "/$ComponentType"

        if ($ComponentUID) {
            $URI = $URI + "/$ComponentUID"
        }

        # Add queries to the URI
        $URI = Build-QueryURI -BaseURI $URI -QueryStrings @{
            limit  = 10
            offset = 0
        }

        do {
            $params = @{
                Method  = 'GET'
                Uri     = $uri
                Headers = @{
                    # Host          = $baseUrl
                    Accept         = "application/json"
                    Authorization  = $token
                    "Content-Type" = "application/json"
                }
            }

            try {
                $response = Invoke-ABWebRequest @params
            } catch {
                "Error : " + $_
            }

            # Add the results to the array
            $allResults += $response.data

            # Increment the offset
            $URI = Build-QueryURI -BaseURI $URI -QueryStrings @{
                offset = $allResults.Count
            }

        } until (
            ($allResults.Count -eq $response.total) -or
            ($allResults.Count -eq $response.total_count)
        )



        return $response
    }
}
