function Get-ConfigurationPath {
    <#
    .SYNOPSIS
        returns hashtable object with the BaseURL, SepCloudCreds, SepCloudToken full path
    .DESCRIPTION
        returns hashtable object with the BaseURL, SepCloudCreds, SepCloudToken full path
    .INPUTS
        None
    .OUTPUTS
        Hashtable
    .NOTES
        Created by: Aurélien BOUMANNE (02122022)
        helper function
    #>

    @{
        BaseUrl       = "api.sep.securitycloud.symantec.com"
        SepCloudCreds = "$env:TEMP\SepCloudOAuthCredentials.xml"
        CachedTokenPath   = "$env:TEMP\SepCloudCachedToken.xml"
    }

}
