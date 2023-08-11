BeforeAll {
    $ScriptName = ($PSCommandPath.Replace('.Tests.ps1', '.ps1')) | Split-Path -Leaf
    . $PSScriptRoot\..\Source\Private\$ScriptName
}

# Describe "Get-SEPCloudToken" {
#     BeforeAll {

#     }

#     It "returns the correct token" {
#         $result = Get-SEPCloudToken
#         $result | Should -BeOfType 'System.String'
#         $result | Should -StartWith 'Bearer: '
#     }
# }


# Test that the function correctly retrieves a token from the local cred file
Describe 'Get-SEPCloudToken' {
    Context 'When a valid cred is present in the local cred file' {
        # Create a mock cred file
        before {
            $cred = 'mock-cred'
            $cred | Export-Clixml -Path 'C:\temp\mock-cred.xml'
        }

        # Test that the function correctly retrieves the token
        It 'Retrieves the token from the local cred file' {
            $result = Get-SEPCloudToken -SepCloudCreds 'C:\temp\mock-cred.xml'
            $result | Should Be 'mock-token'
        }
    }
}

# Test that the function correctly retrieves a token from the prompt
Describe 'Get-SEPCloudToken' {
    Context 'When no valid token or cred is present in local files' {
        # Test that the function correctly retrieves the token
        It 'Retrieves the token from the prompt' {
            $result = Get-SEPCloudToken
            $result | Should Be 'mock-token'
        }
    }
}
