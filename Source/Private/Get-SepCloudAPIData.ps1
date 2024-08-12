            'Get-SEPCloudDeviceDetails'                = @{
                '1.0' = @{
                    Description = 'Details about the SEP client'
                    URI         = '/v1/devices'
                    Method      = 'Get'
                    Body        = ''
                    Query       = @{
                        device_id = 'device_id'
                    }
                    Result      = ''
                    Success     = ''
                    Function    = 'Get-SEPCloudDeviceDetails'
                    ObjectTName = 'SEPCloud.device-details '
                }
            }
