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


    [CmdletBinding(DefaultParameterSetName = 'DefaultSet')]
    param (
        # Group ID
        [Alias("group_id")]
        [string]
        $GroupID,


        # SearchString
        [Parameter()]
        [string]
        $SearchString,

        $bodyvar1,
        $bodyvar2,
        $bodyvar3
    )

    begin {
        # Init
        $function = $MyInvocation.MyCommand.Name
        $resources = Get-SEPCLoudAPIData -endpoint $function
        # $id = "123" # test to remove #TODO to remove
    }

    process {
        $uri = New-URIString -endpoint ($resources.URI) -id $id
        $uri = New-URIQuery -querykeys ($resources.Query.Keys) -parameters $PSBoundParameters -uri $uri

        # Body tests
        # $body = @{
        #     bodyvar1 = $bodyvar1
        #     bodyvar2 = $bodyvar2
        #     bodyvar3 = $bodyvar3
        # }

        Write-Verbose -Message "Body is $body"

        $Request = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body


        return $Request
    }
}
