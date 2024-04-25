function Invoke-ABWebRequest {
    <#
    .SYNOPSIS
        Gather WebRequest from a URL or redirect URL.
    .DESCRIPTION
        Gather WebRequest from a URL or redirect URL. Preserves the Authorization header upon redirect.
    .PARAMETER Uri
        URL to gather WebRequest from.
    .PARAMETER Method
        HTTP method to use.
    .PARAMETER Headers
        Headers to include in the request.
        Must be a hashtable as per example below.
    .OUTPUTS
        JSON object
    .EXAMPLE
        $params = @{
            Method  = 'GET'
            Uri     = "https://example.com/v1/endpoint"
            Headers = @{
                Host          = "https://example.com/v1/endpoint"
                Accept        = "application/json"
                Authorization = "Bearer xxxxxxxx"
            }
        }
        Invoke-ABWebRequest @params
    #>


    [CmdletBinding()]
    param (
        # URL
        [Parameter(Mandatory = $true)]
        [string]$uri,

        # Method
        [Parameter(Mandatory = $true)]
        [string]$method,

        # List of headers
        [Parameter(Mandatory = $true)]
        [hashtable]$headers
    )

    process {
        # Initial request
        $request = [System.Net.WebRequest]::CreateHttp($uri);
        $request.Method = $method
        $request.AllowAutoRedirect = $false

        # Add headers
        foreach ($header in $Headers.GetEnumerator()) {
            $request.Headers.Add($header.Key, $header.Value)
        }
        $inititalResponse = $request.GetResponse();

        # IF HTTP status code is linked to redirected URL
        if ($inititalResponse.StatusCode.value__ -in (301, 302, 303, 307, 308)) {
            # Update host header
            $Headers.Host = $inititalResponse.GetResponseHeader("Location")

            # Create new request with the redirect URL
            $redirectUrl = $inititalResponse.GetResponseHeader("Location")
            $newRequest = [System.Net.WebRequest]::CreateHttp($redirectUrl);
            $newRequest.Method = $Method
            $newRequest.AllowAutoRedirect = $false

            # Populate headers
            # TODO verify why when adding all the headers and not just the Authorization header, the request fails wih 400
            # foreach ($header in $Headers.GetEnumerator()) {
            #     $request.Headers.Add($header.Key, $header.Value)
            # }
            $newRequest.Headers.Add("Authorization", $Headers.Authorization)

            # Send the new request
            $Response = $newRequest.GetResponse()

            # Parse the response
            $stream = $response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $content = $reader.ReadToEnd()
        } else {
            # Get the response from the initial request
            $stream = $inititalResponse.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $content = $reader.ReadToEnd()
        }

        return $content | ConvertFrom-Json -Depth 100
    }
}
