BeforeAll {
    $ScriptName = ($PSCommandPath.Replace('.Tests.ps1', '.ps1')) | Split-Path -Leaf
    . $PSScriptRoot\..\Source\Private\$ScriptName
}

Describe 'Get-SEPCloudToken' {
    It 'Given no parameters, it lists all 8 planets' {
        $token = Get-SEPCloudToken
        $token | Should not be $null
    }
}
