function Get-SEPCLoudAPIData {
    [CmdletBinding()]
    param (
        $endpoint
    )

    process {
        $api = @{
            Example                 = @{
                '1.0' = @{
                    Description = 'Details about the API endpoint'
                    URI         = 'The URI expressed as /api/v#/endpoint'
                    Method      = 'Method to use against the endpoint'
                    Body        = 'Parameters to use in the body'
                    Query       = 'Parameters to use in the URI query'
                    Result      = 'If the result content is stored in a higher level key, express it here to be unwrapped in the return'
                    Filter      = 'If the result content needs to be filtered based on key names, express them here'
                    Success     = 'The expected HTTP status code for a successful call'
                }
            }
            'Connect-SEPCloud'      = @{
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
            'Get-SEPCloudGroupTest' = @{
                '1.0' = @{
                    Description = 'Details about the API endpoint'
                    URI         = '/v1/device-groups'
                    Method      = 'Get'
                    # Body        = @{
                    #     bodyvar1 = 'bodyvar1'
                    #     bodyvar2 = 'bodyvar2'
                    #     bodyvar3 = 'bodyvar3'
                    # }
                    body        = ''
                    # Query       = @{
                    #     'groupId'      = 'groupId'
                    #     'SearchString' = 'query_string'
                    # }
                    Query       = ''
                    Result      = ''
                    Filter      = ''
                    Success     = '200'
                    Function    = 'Get-SEPCloudGroupTest'
                    ObjectTName = 'SEPCloud.Device-Group-List'
                    Definitions = @{
                        'Device-Group-List' = @{
                            count         = 'count'
                            device_groups = @{
                                'Device-Group' = @{
                                    id          = 'id'
                                    name        = 'name'
                                    description = 'description'
                                    created     = 'created'
                                    modified    = 'modified'
                                    parent_id   = 'parent_id'
                                }
                            }
                        }
                    }
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
