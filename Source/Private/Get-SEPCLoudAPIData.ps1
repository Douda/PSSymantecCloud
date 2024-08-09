function Get-SEPCLoudAPIData {
    [CmdletBinding()]
    param (
        $endpoint
    )

    process {
        $api = @{
            'Example'                     = @{
                '1.0' = @{
                    Description = 'Details about the API endpoint'
                    URI         = 'The URI expressed as /api/v#/endpoint'
                    Method      = 'Method to use against the endpoint'
                    Body        = 'Parameters to use in the body'
                    Query       = 'Parameters to use in the URI query'
                    Result      = 'If the result content is stored in a higher level key, express it here to be unwrapped in the return'
                    Success     = 'The expected HTTP status code for a successful call'
                    Function    = 'The PowerShell function to call to process the result'
                    ObjectTName = 'The name of the PSType object to return'
                }
            }
            'Connect-SEPCloud'            = @{
                '1.0' = @{
                    Description = 'Generate new bearer token from the from the oAuth credential'
                    URI         = '/v1/oauth2/tokens'
                    Method      = 'Post'
                    Body        = ''
                    Query       = ''
                    Result      = ''
                    Filter      = ''
                    Success     = '200'
                }
            }
            'Get-SEPCloudGroup'           = @{
                '1.0' = @{
                    Description = 'retrieve a list of device groups'
                    URI         = '/v1/device-groups'
                    Method      = 'Get'
                    body        = ''
                    Query       = @{
                        offset = 'offset'
                    }
                    Result      = 'device_groups'
                    Success     = '200'
                    Function    = 'Get-SEPCloudGroupTest'
                    ObjectTName = 'SEPCloud.Device-Group' # root object is 'SEPCloud.Device-Group-List' but children objects only are exposed as 'SEPCloud.Device-Group'
                }
            }
            'Get-SEPCloudGroupPolicies'   = @{
                '1.0' = @{
                    Description = 'retrieve a list of policies that are targeted on a device group'
                    URI         = '/v1/device-groups/{id}/policies'
                    Method      = 'Get'
                    body        = ''
                    Query       = @{
                        group_id = 'group_id'
                    }
                    Result      = 'policies'
                    Success     = '200'
                    Function    = 'Get-SEPCloudGroupPolicies'
                    ObjectTName = 'SEPCloud.targeted-policy'
                }
            }
            'Get-SepCloudIncidentDetails' = @{
                '1.0' = @{
                    Description = 'retrieve details for a specific incident'
                    URI         = '/v1/incidents'
                    Method      = 'Get'
                    body        = ''
                    Query       = @{
                        incident_id = 'incident_id'
                    }
                    Result      = 'incident'
                    Success     = '200'
                    Function    = 'Get-SepCloudIncidentDetails'
                    ObjectTName = 'SEPCloud.incident-details'
                }
            }
            'Get-SepCloudTargetRules'     = @{
                '1.0' = @{
                    Description = 'retrieve a list of target rules'
                    URI         = '/v1/policies/target-rules'
                    Method      = 'Get'
                    Body        = ''
                    Query       = @{
                        limit  = 'limit'
                        offset = 'offset'
                    }
                    Result      = 'target_rules'
                    Success     = ''
                    Function    = 'Get-SepCloudTargetRules'
                    ObjectTName = 'SEPCloud.target-rule'
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
