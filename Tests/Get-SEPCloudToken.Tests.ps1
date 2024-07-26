BeforeAll {
    $ScriptName = ($PSCommandPath.Replace('.Tests.ps1', '.ps1')) | Split-Path -Leaf
    . $PSScriptRoot\..\Source\Private\$ScriptName
}

Describe "Get-SEPCloudToken" {
    Context "With valid ClientID and Secret" {
        It "Returns a valid token" {
            $ClientID = "myclientid"
            $Secret = "mysecret"
            $Token = Get-SEPCloudToken -ClientID $ClientID -Secret $Secret
            $Token | Should -Not -BeNullOrEmpty
        }
    }

    Context "With invalid ClientID and Secret" {
        It "Throws an error" {
            $ClientID = "invalidclientid"
            $Secret = "invalidsecret"
            { Get-SEPCloudToken -ClientID $ClientID -Secret $Secret } | Should -Throw
        }
    }
}


# # Test that the function correctly retrieves a token from the local cred file
# Describe 'Get-SEPCloudToken' {
#     Context 'When a valid cred is present in the local cred file' {
#         # Create a mock cred file
#         before {
#             $cred = 'mock-cred'
#             $cred | Export-Clixml -Path 'C:\temp\mock-cred.xml'
#         }

#         # Test that the function correctly retrieves the token
#         It 'Retrieves the token from the local cred file' {
#             $result = Get-SEPCloudToken -SEPCloudCredsPath 'C:\temp\mock-cred.xml'
#             $result | Should Be 'mock-token'
#         }
#     }
# }

# # Test that the function correctly retrieves a token from the prompt
# Describe 'Get-SEPCloudToken' {
#     Context 'When no valid token or cred is present in local files' {
#         # Test that the function correctly retrieves the token
#         It 'Retrieves the token from the prompt' {
#             $result = Get-SEPCloudToken
#             $result | Should Be 'mock-token'
#         }
#     }
# }
