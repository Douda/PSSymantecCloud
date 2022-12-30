BeforeAll {
    $ScriptName = ($PSCommandPath.Replace('.Tests.ps1', '.ps1')) | Split-Path -Leaf
    . $PSScriptRoot\..\Source\Private\$ScriptName
}

Describe 'Get-ConfigurationPath' {
    It 'Should return hashtable' {
        $conf = Get-ConfigurationPath
        $conf.Count | Should -Be 3
    }
}
