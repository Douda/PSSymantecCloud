BeforeAll {
    $ScriptName = ($PSCommandPath.Replace('.Tests.ps1', '.ps1')) | Split-Path -Leaf
    . $PSScriptRoot\..\Source\Private\$ScriptName
}

Describe 'Get-SEPCloudToken' {
    It 'Given no parameters, it lists all 8 planets' {
        $token = Get-SEPCloudToken
        $token | Should -Be [string]
    }
}

# Test that the function correctly retrieves a token from the local token file
Describe 'Get-SEPCloudToken' {
    Context 'When a valid token is present in the local token file' {
        # Create a mock token file
        before {
            $token = 'mock-token'
            $token | Export-Clixml -Path 'C:\temp\mock-token.xml'
        }

        # Test that the function correctly retrieves the token
        It 'Retrieves the token from the local token file' {
            $result = Get-SEPCloudToken -SepCloudToken 'C:\temp\mock-token.xml'
            $result | Should Be 'mock-token'
        }
    }
}

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
