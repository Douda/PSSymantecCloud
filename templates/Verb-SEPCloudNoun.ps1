function Verb-SEPCloudNoun {

    <#
        .SYNOPSIS
        {required: high level overview}

        .DESCRIPTION
        {required: more detailed description of the function's purpose}

        .NOTES
        Written by {required}
        Twitter: {optional}
        GitHub: {optional}
        Any other links you'd like here

        .LINK
        https://github.com/Douda/PSSymantecCloud

        .EXAMPLE
        {required: show one or more examples using the function}
    #>
    [CmdletBinding()]
    Param(
        # {param details}
        [String]$Param1,
        # {param details}
        [String]$Param2,
        # {param details}
        [String]$Param3
    )

    begin {

        # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
        # If a command needs to be run with each iteration or pipeline input, place it in the Process section

        # Check to ensure that a session to the SaaS exists and load the required data for authentication
        Test-SEPCloudConnection

        # API data references the name of the function
        # For convenience, that name is saved here to $function
        $function = $MyInvocation.MyCommand.Name

        # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
        Write-Verbose -Message "Gather API Data for $function"
        $resources = Get-RubrikAPIData -endpoint $function
        Write-Verbose -Message "Load API data for $($resources.Function)"
        Write-Verbose -Message "Description: $($resources.Description)"
    }

    process {
        # TODO template work in progress
        $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
        # $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
        $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body

        return $result
    }

    end {

    }
}
