
function Submit-Request {
    [cmdletbinding()]
    param(
        # The endpoint's URI
        $uri,
        # The header containing authentication details
        $header = $script:SEPCloudConnection.header,
        # The action (method) to perform on the endpoint
        $method = $($resources.Method),
        # Any optional body data being submitted to the endpoint
        $body
    )


    Write-Verbose -Message 'Submitting the request'

    $WebResult = Invoke-SEPCloudWebRequest -Uri $uri -Headers $header -Method $method -Body $body

    return $WebResult

}
