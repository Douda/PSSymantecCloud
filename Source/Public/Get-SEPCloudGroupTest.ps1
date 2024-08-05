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
    param ()

    begin {
        # Init
        $function = $MyInvocation.MyCommand.Name
        $resources = Get-SEPCLoudAPIData -endpoint $function
    }

    process {
        $uri = New-URIString -endpoint ($resources.URI) -id $id
        $uri = New-URIQuery -querykeys ($resources.Query.Keys) -parameters $PSBoundParameters -uri $uri

        Write-Verbose -Message "Body is $body"
        $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body

        # Test if pagination required
        if ($resources.Definitions.$definition.count -or $resources.Definitions.$definition.total) {
            Write-Verbose -Message "Result limits hit. Retrieving remaining data based on pagination"
            $allResults += $result

            do {
                # Update the offset as query parameter (add it if empty, replace it if existing)
                $query = $resources.query
                if ($query -ne "" -and $query.ContainsKey('offset')) {
                    $query.offset = $allResults.device_groups.count
                } elseif ($query -eq "") {
                    $query = [hashtable]@{ offset = $allResults.device_groups.count }
                } else {
                    $query.add('offset', $allResults.device_groups.count)
                }
                $resources.query = $query

                $uri = New-URIQuery -querykeys ($resources.Query.Keys) -parameters $PSBoundParameters -uri $uri
                $nextResult = Submit-Request  -uri $uri  -header $script:SEPCloudConnection.header  -method $($resources.Method) -body $body
                $allResults.device_groups += $nextResult.device_groups
            } until ($allResults.device_groups.count -ge $allResults.total)
        }

        return $allResults
    }
}
