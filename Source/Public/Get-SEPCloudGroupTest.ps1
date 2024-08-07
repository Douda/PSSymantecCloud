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
        # Query
        [Alias('api_page')]
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

        return $result
    }
}
