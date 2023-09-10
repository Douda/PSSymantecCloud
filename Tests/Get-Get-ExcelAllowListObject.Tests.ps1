BeforeAll {
    $ScriptName = ($PSCommandPath.Replace('.Tests.ps1', '.ps1')) | Split-Path -Leaf
    . $PSScriptRoot\..\Source\Private\$ScriptName
}

# TODO: Add tests & verify they work
Describe 'Get-ExcelAllowListObject' {
    It 'Returns an object with the expected properties' {
        $AllowListObject = Get-ExcelAllowListObject
        $AllowListObject | Should BeOfType [System.Management.Automation.PSCustomObject]
        $AllowListObject | Should HaveMember 'Extension'
        $AllowListObject | Should HaveMember 'ContentType'
        $AllowListObject | Should HaveMember 'Allowed'
        $AllowListObject | Should HaveMember 'Blocked'
    }

    It 'Returns an object with at least one allowed extension' {
        $AllowListObject = Get-ExcelAllowListObject
        $AllowListObject.Allowed | Should Not BeNullOrEmpty
    }

    It 'Returns an object with at least one blocked extension' {
        $AllowListObject = Get-ExcelAllowListObject
        $AllowListObject.Blocked | Should Not BeNullOrEmpty
    }

    It 'Returns an object with valid content types' {
        $AllowListObject = Get-ExcelAllowListObject
        $AllowListObject.ContentType | Should ContainOnly 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    }
}
