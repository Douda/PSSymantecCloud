# Testing Pester
# 1st attempt
function Do-Thing {
    param (
        # Test
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [pscredential]$Credential
    )

    Get-aduser -filter * -credential $Credential

}

Describe 'NewMockObject demo' {
    $testCred = New-MockObject -Type 'System.Management.Automation.PSCredential'
}
