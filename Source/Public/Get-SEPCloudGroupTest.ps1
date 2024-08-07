function Get-SEPCloudGroupTest {

    # This is a POC for the redesign
    # Includes comments and will be used a reference / template for future work

    # Comments
    # General design
    #################
    # - API endpoint customization will be set in the Get-SEPCloudAPIData function
    # - Every function interacting with the API endpoints will g

    # PSBoundParameters
    ###################
    # Alias is included in $PSBoundParameters
    # $PSBountParameters does not take default inputs as a parameter
    # See https://github.com/PowerShell/PowerShell/issues/3285


    [CmdletBinding()]
    param (
        # Tests Body
        $bodyvar1,
        $bodyvar2,
        $bodyvar3,

        # Test Query
        $groupId,
        $SearchString,

        # Query
        [Aliass('api_page')]
        $offset
    )

    begin {
        # Check to ensure that a session to the SaaS exists and load the needed header data for authentication
        Test-SEPCloudConnection | Out-Null

        # Init
        $function = $MyInvocation.MyCommand.Name
        $resources = Get-SEPCLoudAPIData -endpoint $function
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
            $allResults += $result

            do {
                $offset = $allResults.device_groups.count
                # Use the updated query to retrieve the next page of results ($resources.query)
                $uri = Test-QueryParam -querykeys $resources.query -parameters ((Get-Command $function).Parameters.Values) -uri $uri
                $nextResult = Submit-Request  -uri $uri  -header $script:SEPCloudConnection.header  -method $($resources.Method) -body $body
                $allResults.device_groups += $nextResult.device_groups
            } until ($allResults.device_groups.count -ge $allResults.total)
        }

        if ($allResults) {
            return $allResults
        } else {
            return $result
        }
    }
}
