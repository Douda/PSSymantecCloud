Describe 'Get-ExcelAllowListObject' {
    # Create a test file
    $testFile = 'WorkstationsAllowListPolicy.xlsx'
    $testFilePath = Join-Path $env:TEMP $testFile
    $testSheet = 'Applications'
    $testSheetData = @(
        [pscustomobject]@{
            sha2 = '1234567890'
            Name = 'TestApp'
        }
    )
    $testSheetData | Export-Excel $testFilePath -WorksheetName $testSheet -Force

    It 'imports excel allow list report as a PSObject' {
        $result = Get-ExcelAllowListObject -Excel $testFile
        # Check if the result is of the correct type (custom PSObject)
        $result | Should BeOfType 'ExceptionStructure'
        # Check if the data in the result is as expected
        $result.Applications | Should Contain @{
            sha2 = '1234567890'
            Name = 'TestApp'
        }
    }

    # Cleanup
    after {
        Remove-Item -Path $testFilePath -Force
    }
}
