function Get-SEPCloudGroupTest {

    # This is a POC for the redesign
    # Includes comments and will be used a reference / template for future work

    # Comments
    # General design
    #################
    # - API endpoint customization will be set in the Get-SEPCloudAPIData function
    # - Every function interacting with the API endpoints will get its source from Get-SEPCloudAPIData function


    [CmdletBinding()]
    param (
        # Query
        [Alias('api_page')]
        $offset
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

        Write-Verbose -Message "Body is $(ConvertTo-Json -InputObject $body)"
        $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body

        # Test if pagination required
        if ($result.total -gt $result.device_groups.count) {
            Write-Verbose -Message "Result limits hit. Retrieving remaining data based on pagination"
            do {
                # Update offset query param for pagination
                $offset = $result.device_groups.count
                $uri = Test-QueryParam -querykeys $resources.query -parameters ((Get-Command $function).Parameters.Values) -uri $uri
                $nextResult = Submit-Request  -uri $uri  -header $script:SEPCloudConnection.header  -method $($resources.Method) -body $body
                $result.device_groups += $nextResult.device_groups
            } until ($result.device_groups.count -ge $result.total)
        }

        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

        # Add custom property fullPathName
        $result | ForEach-Object {
            $fullPathName = Get-SEPCloudGroupFullPath -CurrentGroup $_ -AllGroups $result -Chain ""
            $_ | Add-Member -NotePropertyName "fullPathName" -NotePropertyValue $fullPathName.TrimEnd(" > ")
        }

        return $result
    }
}
