Describe "Test-SepCloudConnectivity" {
    BeforeAll {
        # Mock the Get-SEPCloudToken function to always return a valid token
        Mock Get-SEPCloudToken { 'abc123' }
    }

    It "returns true when authentication succeeds" {
        $result = Test-SepCloudConnectivity
        $result | Should -Be $true
    }

    It "returns false when authentication fails" {
        # Mock the Get-SEPCloudToken function to return $null
        Mock Get-SEPCloudToken { $null }

        $result = Test-SepCloudConnectivity
        $result | Should -Be $false
    }
}
