function Get-SEPCloudGroupTest {

    # This is a POC for the redesign
    # Includes comments and will be used a reference / template for future work

    # Comments

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
        $SearchString
    )

    begin {
        # Init
        $function = $MyInvocation.MyCommand.Name
        $resources = Get-SEPCLoudAPIData -endpoint $function
        # $id = "123" # test to remove
    }

    process {
        $uri = New-URIString -endpoint ($resources.URI) -id $id
        $uri = New-URIQuery -querykeys ($resources.Query.Keys) -parameters $PSBoundParameters -uri $uri

        return $uri
    }
}
