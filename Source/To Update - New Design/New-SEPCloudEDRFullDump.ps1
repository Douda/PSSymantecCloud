function New-SEPCloudEDRFullDump {

    <#
        .SYNOPSIS
            lets you send the full dump command on the device
        .DESCRIPTION
            lets you send the full dump command on the device
            By default the command will have time range of from 29 days to 10 minutes ago
        .LINK
            https://github.com/Douda/PSSymantecCloud
        .PARAMETER device_id
        device id of the client to send to the command to
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]
        $device_id,

        # [Parameter(Mandatory = $true)]
        [string]
        $description,

        $from_date = ((Get-Date).AddDays(-29) | Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffK"), # Default is 29 days ago
        $to_date = ((Get-Date).AddMinutes(-10) | Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffK") # Default is 10 minutes ago
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
        # Description is a mandatory parameter but is not enforced for convinience
        # If the description is not provided, then generate a default one based off the computer details
        if (-not $description) {
            Write-Information -Message "No description provided for $($resources.Function)"
            $deviceDetails = Get-SepCloudDeviceDetails -Device_ID $device_id
            $description = "$($deviceDetails.name) - from $($from_date) - to $($to_date)"
            Write-Information -Message "Description will be : $($description)"

        }
        $uri = New-URIString -endpoint ($resources.URI)
        $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)

        Write-Verbose -Message "Body is $(ConvertTo-Json -InputObject $body)"
        $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body

        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

        return $result
    }
}
