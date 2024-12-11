# Load module
$ProjectPath = "$PSScriptRoot/../.." | Convert-Path
$ProjectName = (Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object {
($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false }) }
).BaseName
. (Join-Path -Path $ProjectPath -ChildPath 'Tests/Config/Common-InitializeProjectModule.ps1')


AfterAll {
    # This is common test code teardown logic for all Pester test files
    $ProjectPath = "$PSScriptRoot/../.." | Convert-Path
    . (Join-Path -Path $ProjectPath -ChildPath 'Tests/Config/Common-AfterAll.ps1')
}


InModuleScope $ProjectName {
    Describe "Get-SEPCloudToken" {
        BeforeEach {
            # Load test environment
            $ProjectPath = "$PSScriptRoot/../.." | Convert-Path
            . (Join-Path -Path $ProjectPath -ChildPath 'Tests/Config/Common-InitializeTestEnvironment.ps1')

            Mock Invoke-RestMethod { [PSCustomObject]@{
                    access_token = "pester-mocked-token";
                    token_type   = "pester-bearer";
                    Token_Bearer = "pester-mocked-token" + " " + "pester-bearer";
                    Expiration   = (Get-Date).AddSeconds(3600)
                }
            }
            Mock Read-Host -ParameterFilter { $prompt -eq "Enter clientId" } { "pester-cliend-id" }
            Mock Read-Host -ParameterFilter { $prompt -eq "Enter secret" } { "pester-secret-id" }
        }

        Context "With ClientID and Secret parameters" {
            BeforeEach {
                $clientID = "pester-clientid"
                $secret = "pester-secretid"
                $result = Get-SEPCloudToken -ClientID $clientID -Secret $secret
                $result
            }

            It "returns a new token" {
                $result | Should -Not -BeNullOrEmpty
                Assert-MockCalled -CommandName Invoke-RestMethod -Exactly 1 -Scope It
                $result.token | Should -Be "pester-mocked-token"
            }

            It "Loads token in memory " {
                $script:SEPCloudConnection.AccessToken.Token | Should -Be 'pester-mocked-token'
            }

            It "Saves token to file" {
                Test-Path -Path ($script:configuration).cachedTokenPath | Should -Be $true
                $cachedToken = Import-Clixml -Path $script:configuration.cachedTokenPath
                $cachedToken.Token | Should -Be 'pester-mocked-token'
            }
        }

        Context "With -cacheOnly flag" {
            Mock Read-Host -ParameterFilter { $prompt -eq "Enter clientId" } { "pester-cliend-id" }
            Mock Read-Host -ParameterFilter { $prompt -eq "Enter secret" } { "pester-secret-id" }

            $result = Get-SEPCloudToken -cacheOnly
            $result | Should -Be $null
        }

        Context "no parameters" {
            Context "Setup token from memory" {
                BeforeEach {
                    $script:SEPCloudConnection.AccessToken = [PSCustomObject]@{
                        access_token = "pester-mocked-token-from-memory";
                        token_type   = "pester-bearer";
                        Token_Bearer = "pester-mocked-token" + " " + "pester-bearer";
                        Expiration   = (Get-Date).AddSeconds(3600)
                    }
                }

                It "Returns valid token from memory" {
                    $result = Get-SEPCloudToken
                    $result.access_token | Should -Be 'pester-mocked-token-from-memory'
                }

                It "Returns new valid token if cached one is expired" {
                    $script:SEPCloudConnection.AccessToken = [PSCustomObject]@{
                        access_token = "pester-mocked-token-from-memory";
                        token_type   = "pester-bearer";
                        Token_Bearer = "pester-mocked-token" + " " + "pester-bearer";
                        Expiration   = (Get-Date).AddSeconds(-3600)
                    }

                    $result = Get-SEPCloudToken
                    $result.Token | Should -Be 'pester-mocked-token'
                }
            }

            Context "Setup token from disk" {
                BeforeEach {
                    # No in-memory cache
                    $script:SEPCloudConnection.AccessToken = $null

                    Mock -CommandName Test-SEPCloudToken { $true }
                    Mock -CommandName Test-Path -MockWith {
                        param ($Path)
                        if ($Path -eq "TestDrive:\accessToken.xml") {
                            return $true
                        }
                        return $false
                    }
                }

                It "Returns valid token from disk" {
                    $result = Get-SEPCloudToken
                    $result.token | Should -Be "pester-token"
                }
            }

            Context "Setup credentials from disk" {
                BeforeEach {
                    # No in-memory cache
                    $script:SEPCloudConnection.AccessToken = $null

                    # No credentials in cache
                    Mock -CommandName Test-Path  -MockWith { return $false } -ParameterFilter {
                        $path -eq $script:configuration.cachedTokenPath
                    }
                }

                It "Returns new token from available credentials" {
                    # No in-memory cache
                    $script:SEPCloudConnection.AccessToken = $null
                    # No local file cache
                    Remove-Item -Path $script:configuration.cachedTokenPath

                    $result = Get-SEPCloudToken
                    $result.token | Should -Be "pester-mocked-token"
                }
            }
        }
    }
}
