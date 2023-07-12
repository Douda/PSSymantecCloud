# BeforeAll {
#     $ScriptName = ($PSCommandPath.Replace('.Tests.ps1', '.ps1')) | Split-Path -Leaf
#     . $PSScriptRoot\..\Source\Private\$ScriptName
# }

# Describe 'Get-ConfigurationPath' {
#     It 'Should return hashtable' {
#         $conf = Get-ConfigurationPath
#         $conf.Count | Should -Be 3
#     }
# }

Describe "Get-ConfigurationPath" {
    It "returns a hashtable object" {
        $result = Get-ConfigurationPath
        $result | Should BeOfType Hashtable
    }
    It "has a key 'BaseUrl' with the correct value" {
        $result = Get-ConfigurationPath
        $result.BaseUrl | Should Be 'api.sep.securitycloud.symantec.com'
    }
    It "has a key 'SepCloudCreds' with the correct value" {
        $result = Get-ConfigurationPath
        $result.SepCloudCreds | Should Be "$env:TEMP\SepCloudOAuthCredentials.xml"
    }
    It "has a key 'SepCloudToken' with the correct value" {
        $result = Get-ConfigurationPath
        $result.SepCloudToken | Should Be "$env:TEMP\SepCloudToken.xml"
    }
}
