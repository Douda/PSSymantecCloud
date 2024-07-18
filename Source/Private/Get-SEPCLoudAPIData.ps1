function Get-SEPCLoudAPIData {
    [CmdletBinding()]
    param (
        $endpoint
    )

    process {
        $api = @{
            'Get-SEPCloudGroupTest' = @{
                '1.0' = @{
                    Description = 'Details about the API endpoint'
                    URI         = '/v1/device-groups'
                    Method      = 'Get'
                    Body        = ''
                    Query       = @{
                        'groupId'      = 'groupId'
                        'SearchString' = 'query_string'
                    }
                    Result      = ''
                    Filter      = ''
                    Success     = '200'
                    Function    = 'Get-SEPCloudGroupTest'
                }
            }
        }

        # Use the latest version of the API endpoint
        $version = $api.$endpoint.Keys | Sort-Object | Select-Object -Last 1

        if ($null -eq $version) {
            $ErrorSplat = @{
                Message      = "No matching endpoint found for $Endpoint that corresponds to the current cluster version."
                ErrorAction  = 'Stop'
                TargetObject = $api.$endpoint.keys -join ','
                Category     = 'ObjectNotFound'
            }
            Write-Error @ErrorSplat
        } else {
            Write-Verbose -Message "Selected $version API Data for $endpoint"
            return $api.$endpoint.$version
        }
    }
}
