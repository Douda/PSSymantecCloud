# Load module
$ProjectPath = "$PSScriptRoot/../.." | Convert-Path
. (Join-Path -Path $ProjectPath -ChildPath 'Tests/Config/Common-InitializeProjectModule.ps1')

$ProjectName = (Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object {
    ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false }) }
).BaseName

AfterAll {
    # This is common test code teardown logic for all Pester test files
    $ProjectPath = "$PSScriptRoot/../.." | Convert-Path
    . (Join-Path -Path $ProjectPath -ChildPath 'Tests/Config/Common-AfterAll.ps1')
}


InModuleScope $ProjectName {
    Describe "Test-SEPCloudToken" {
        BeforeAll {
            # Load test environment
            $ProjectPath = "$PSScriptRoot/../.." | Convert-Path
            . (Join-Path -Path $ProjectPath -ChildPath 'Tests/Config/Common-InitializeTestEnvironment.ps1')
        }

        Context "Token stored in memory" {
            It "valid token" {
                $script:SEPCloudConnection.AccessToken = [PSCustomObject]@{
                    Token        = "test-token"
                    Token_Type   = "Bearer"
                    Token_Bearer = "Bearer" + " " + "test-token"
                    Expiration   = (Get-Date).AddSeconds(3600)
                }
                $result = Test-SEPCloudToken
                $result | Should -Be $true
            }

            It "expired token" {
                $script:SEPCloudConnection.AccessToken = [PSCustomObject]@{
                    Token        = "test-token"
                    Token_Type   = "Bearer"
                    Token_Bearer = "Bearer" + " " + "validToken"
                    Expiration   = (Get-Date).AddSeconds(-3600)
                }
                $result = Test-SEPCloudToken
                $result | Should -Be $false
            }

            It "deletes expired token from disk" {
                $script:SEPCloudConnection.AccessToken = [PSCustomObject]@{
                    Token        = "test-token"
                    Token_Type   = "Bearer"
                    Token_Bearer = "Bearer" + " " + "validToken"
                    Expiration   = (Get-Date).AddSeconds(-3600)
                }
                Test-SEPCloudToken
                Test-Path -Path ($script:configuration).CachedTokenPath | Should -Be $false
            }
        }

        Context "No token available" {
            It "no token in memory" {
                $script:SEPCloudConnection.AccessToken = $null
                $result = Test-SEPCloudToken
                $result | Should -Be $false
            }
        }
    }
}
