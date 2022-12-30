BeforeAll {

}

Describe 'Get-SEPCloudToken' {
    It 'Given no parameters, it lists all 8 planets' {
        $allPlanets = Get-Planet
        $allPlanets.Count | Should -Be 3
    }
}
