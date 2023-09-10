BeforeAll {
    $ScriptName = ($PSCommandPath.Replace('.Tests.ps1', '.ps1')) | Split-Path -Leaf
    . $PSScriptRoot\..\Source\Public\$ScriptName
}

# TODO: Add tests & verify they work
Describe 'Get-EDRDumps' {
    It 'Returns an array of commands' {
        $Commands = Get-EDRDumps
        $Commands | Should BeOfType [System.Object[]]
    }

    It 'Returns at least one command' {
        $Commands = Get-EDRDumps
        $Commands | Should Not BeNullOrEmpty
    }

    It 'Returns commands with valid properties' {
        $Commands = Get-EDRDumps
        $Commands | ForEach-Object {
            $_ | Should HaveMember 'id'
            $_ | Should HaveMember 'name'
            $_ | Should HaveMember 'description'
            $_ | Should HaveMember 'platform'
            $_ | Should HaveMember 'created_at'
            $_ | Should HaveMember 'updated_at'
        }
    }

    It 'Returns commands with valid platform values' {
        $Commands = Get-EDRDumps
        $Commands | ForEach-Object {
            $_.platform | Should BeOneOf 'Windows', 'Linux', 'Mac'
        }
    }
}
