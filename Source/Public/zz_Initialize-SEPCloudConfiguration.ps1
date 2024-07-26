####################################
# Init script for the whole module #
####################################

## This is the initialization script for the module.  It is invoked at the end of the module's
## prefix file as "zz_" to load this module at last.  This is done to ensure that all other functions are first loaded
## This function should be private but will stay Public for the moment as it needs to be the last function to be loaded in the module
## TODO make this function private

# Update the data types when loading the module
Update-TypeData -PrependPath (Join-Path -Path $PSScriptRoot -ChildPath 'PSSymantecCloud.Types.ps1xml')

# The credentials used to authenticate to the SES Cloud API
[string]         $script:Credential = $null # string type used as credentials is OAuth2 token
[PSCustomObject] $script:accessToken = $null

# The session-cached copy of the module's configuration properties
# Configuration contains user-defined properties
# SEPCloudConnection contains the connection information to the SES Cloud API
[PSCustomObject] $script:configuration = $null
[PSCustomObject] $script:SEPCloudConnection = [PSCustomObject]@{
    BaseURL     = "api.sep.securitycloud.symantec.com"
    Credential  = $null
    AccessToken = $null
    time        = (Get-Date)
    header      = $null
}

# Module name
[string] $script:ModuleName = "PSSymantecCloud"

# Load the configuration file
$script:configuration = [PSCustomObject]@{
    BaseURL           = "api.sep.securitycloud.symantec.com"
    SEPCloudCredsPath = [System.IO.Path]::Combine(
        [System.Environment]::GetFolderPath('LocalApplicationData'),
        'PSSymantecCloud',
        'creds.xml')
    CachedTokenPath   = [System.IO.Path]::Combine(
        [System.Environment]::GetFolderPath('LocalApplicationData'),
        'PSSymantecCloud',
        'accessToken.xml')
}


function Initialize-SEPCloudConfiguration {
    <#
    .SYNOPSIS
        Populates the configuration of the module for this session, loading in any values
        that may have been saved to disk.

    .DESCRIPTION
        Populates the configuration of the module for this session, loading in any values
        that may have been saved to disk.

    .NOTES
        Internal helper method.  This is actually invoked at the END of this file.
    #>
    [CmdletBinding()]
    param()

    # Load credential from disk if it exists
    if (Test-Path -Path $($script:configuration.SEPCloudCredsPath)) {
        try {
            $script:Credential = Import-Clixml -Path $($script:configuration.SEPCloudCredsPath)
            $script:SEPCloudConnection.Credential = $script:Credential
        } catch {
            Write-Verbose "No credentials found from $($script:configuration.SEPCloudCredsPath)"
        }
    }

    # Load access token from disk
    if (Test-Path -Path $($script:configuration.CachedTokenPath)) {
        try {
            $script:accessToken = Import-Clixml -Path $($script:configuration.CachedTokenPath)
            $script:SEPCloudConnection.AccessToken = $script:accessToken
        } catch {
            Write-Verbose "Failed to import access token from $($script:configuration.CachedTokenPath): $_" -Verbose
        }
    }
}

# Invoke the initialization method to populate the configuration
Initialize-SEPCloudConfiguration
