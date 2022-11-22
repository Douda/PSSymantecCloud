function GetConfigurationPath {
    <#
        .SYNOPSIS
            returns an object with the BaseURL, SepCloudCreds, SepCloudToken full path
    #>

    @{
        BaseUrl       = "api.sep.securitycloud.symantec.com"
        SepCloudCreds = "$env:TEMP\SepCloudOAuthCredentials.xml"
        SepCloudToken = "$env:TEMP\SepCloudToken.xml"
    }

}
