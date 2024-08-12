function Get-SEPCLoudAPIData {
    [CmdletBinding()]
    param (
        $endpoint
    )

    process {
        $api = @{
            'Example'                               = @{
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
            'Connect-SEPCloud'                      = @{
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
            'Get-SEPCloudComponentType'             = @{
                '1.0' = @{
                    Description = 'lets you retrieve policy component host-groups, network-adapters(adapter), network-services(Connection), network IPS details'
                    URI         = '/v1/policies/components'
                    Method      = 'Get'
                    Body        = ''
                    Query       = @{
                        'offset' = 'offset'
                        'limit'  = 'limit'
                    }
                    Result      = 'data'
                    Success     = ''
                    Function    = 'Get-SEPCloudComponentType'
                    ObjectTName = 'SEPCloud.policyComponentType' # generic PSObject but there could be up to 4 different subtypes
                    # host-group-response
                    # network-services
                    # network-adapter
                    # network_ips_response
                }
            }
            'Get-SEPCloudDevice'                    = @{
                '1.0' = @{
                    Description = 'retrieve the list of devices'
                    URI         = '/v1/devices'
                    Method      = 'Get'
                    Body        = ''
                    Query       = @{
                        offset               = 'offset'
                        client_version       = 'client_version'
                        device_group         = 'device_group' # ID of the parent device group
                        device_status        = 'device_status'
                        device_status_reason = 'device_status_reason'
                        device_type          = 'device_type'
                        edr_enabled          = 'edr_enabled'
                        ipv4_address         = 'ipv4_address'
                        include_details      = 'include_details' # flag to include product and feature details in response. Possible values: true/false
                        is_cloud             = 'is_cloud'
                        is_online            = 'is_online'
                        is_virtual           = 'is_virtual'
                        mac_address          = 'mac_address'
                        name                 = 'name'
                        os                   = 'os' # Possible values: windows, Linux, iOS, Mac, Android
                        os_version           = 'os_version'
                    }
                    Result      = 'devices'
                    Success     = ''
                    Function    = 'Get-SEPCloudDevice'
                    ObjectTName = 'SEPCloud.Device'
                }
            }
            'Get-SEPCloudEvents'                    = @{
                '1.0' = @{
                    Description = 'retrieve up to ten thousand events'
                    URI         = '/v1/event-search'
                    Method      = 'Post'
                    Body        = @{
                        feature_name = 'feature_name'
                        product      = 'product'
                        query        = 'query'
                        start_date   = 'start_date'
                        end_date     = 'end_date'
                        next         = 'next'
                        limit        = 'limit'
                    }
                    Query       = ''
                    Result      = 'events'
                    Success     = ''
                    Function    = 'Get-SEPCloudEvents'
                    ObjectTName = 'SEPCloud.Event'
                }
            }
            'Get-SEPCloudGroup'                     = @{
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
            'Get-SEPCloudGroupPolicies'             = @{
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
            'Get-SepCloudIncidentDetails'           = @{
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
            'Get-SEPCloudPolicesSummary'            = @{
                '1.0' = @{
                    Description = 'retrieve a list of your policies (without details)'
                    URI         = '/v1/policies'
                    Method      = 'Get'
                    Body        = ''
                    Query       = @{
                        limit  = 'limit'
                        offset = 'offset'
                        name   = 'name'
                        type   = 'type'
                    }
                    Result      = 'policies'
                    Success     = ''
                    Function    = 'Get-SEPCloudPolicesSummary'
                    ObjectTName = 'SEPCloud.policy'
                }
            }
            'Get-SepCloudTargetRules'               = @{
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
            'Get-SEPCloudThreatIntelFileProtection' = @{
                '1.0' = @{
                    Description = 'returns information whether a given file has been blocked by any Symantec technologies'
                    URI         = '/v1/threat-intel/protection/file'
                    Method      = 'Get'
                    Body        = ''
                    Query       = ''
                    Result      = ''
                    Success     = ''
                    Function    = 'Get-SEPCloudThreatIntelFileProtection'
                    ObjectTName = 'SEPCloud.file-protection'
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
