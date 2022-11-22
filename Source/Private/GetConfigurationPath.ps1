# ## Global variables
# $Global:BaseURL = "api.sep.securitycloud.symantec.com"
# $Global:SepCloudCreds = "$env:TEMP\SepCloudOAuthCredentials.xml"
# $Global:SepCloudToken = "$env:TEMP\SepCloudToken.xml"
# TODO convert global variables by using the function GetConfigurationPath instead

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