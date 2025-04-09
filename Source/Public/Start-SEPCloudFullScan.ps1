function Start-SEPCloudFullScan {

    <#
        .SYNOPSIS
        {required: high level overview}
        .DESCRIPTION
        {required: more detailed description of the function's purpose}
        .LINK
        https://github.com/Douda/PSSymantecCloud
        .PARAMETER Param1
        {required: description of Param1}
        .PARAMETER Param2
        {required: description of Param2}
        .PARAMETER Param3
        {required: description of Param3}
        .EXAMPLE
        {required: show one or more examples using the function}
    #>

    [CmdletBinding()]
    Param(
        [Alias('deviceId')]
        [string[]]
        $device_ids,

        [string[]]
        [Alias('orgId')]
        $org_unit_ids,

        [Alias('recursive')]
        [switch]
        $is_recursive
    )

    begin {
        # Check to ensure that a session to the SaaS exists and load the needed header data for authentication
        Test-SEPCloudConnection | Out-Null

        # API data references the name of the function
        # For convenience, that name is saved here to $function
        $function = $MyInvocation.MyCommand.Name

        # Retrieve all of the URI, method, body, query, result, and success details for the API endpoint
        Write-Verbose -Message "Gather API Data for $function"
        $resources = Get-SEPCLoudAPIData -endpoint $function
        Write-Verbose -Message "Load API data for $($resources.Function)"
        Write-Verbose -Message "Description: $($resources.Description)"
    }

    process {
        $uri = New-URIString -endpoint ($resources.URI) -id $id
        $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
        $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body
        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result
        return $result
    }
}
