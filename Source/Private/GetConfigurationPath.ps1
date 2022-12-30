function Get-ConfigurationPath {
    <#
    .SYNOPSIS
        returns hashtable object with the BaseURL, SepCloudCreds, SepCloudToken full path
    .DESCRIPTION
    .INPUTS
        None
    .OUTPUTS
        Hashtable
    #>

    @{
        BaseUrl       = "api.sep.securitycloud.symantec.com"
        SepCloudCreds = "$env:TEMP\SepCloudOAuthCredentials.xml"
        SepCloudToken = "$env:TEMP\SepCloudToken.xml"
    }

}
