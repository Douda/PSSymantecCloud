function Get-SEPCloudDevice {
    <#
    .SYNOPSIS
    Gathers list of devices from the SEP Cloud console
    .PARAMETER Computername
    Specify one or many computer names. Accepts pipeline input
    Supports partial match
    .PARAMETER is_online
    Switch to lookup only online machines
    .PARAMETER Device_status
    Lookup devices per security status. Accepts only "SECURE", "AT_RISK", "COMPROMISED", "NOT_COMPUTED"
    .PARAMETER include_details
    Switch to include details in the output
    .PARAMETER Device_group
    Specify a device group ID to lookup. Accepts only device group ID, no group name
    .EXAMPLE
    Get-SEPCloudDevice
    Get all devices (very slow)
    .EXAMPLE
    Get-SEPCloudDevice -Computername MyComputer
    Get detailed information about a computer
    .EXAMPLE
    "MyComputer" | Get-SEPCloudDevice
    Get detailed information about a computer
    .EXAMPLE
    Get-SEPCloudDevice -Online -Device_status AT_RISK
    Get all online devices with AT_RISK status
    .EXAMPLE
    Get-SEPCloudDevice -group "Aw7oerlBROSIl9O_IPFewx"
    Get all devices in a device group
    .EXAMPLE
    Get-SEPCloudDevice -Client_version "14.3.9681.7000" -Device_type WORKSTATION
    Get all workstations with client version 14.3.9681.7000
    .EXAMPLE
    Get-SEPCloudDevice -EdrEnabled -Device_type SERVER
    Get all servers with EDR enabled
    .EXAMPLE
    Get-SEPCloudDevice -IPv4 "192.168.1.1"
    Get all devices with IPv4 address
    #>

    [CmdletBinding()]
    param (
        # Optional ComputerName parameter
        [Parameter(ValueFromPipeline = $true)]
        [string]
        $Computername,

        # Optional Is_Online parameter
        [Parameter()]
        [Alias("Online")]
        [switch]
        $is_online,

        # Optional include_details parameter
        [Parameter()]
        [Alias("Details")]
        [switch]
        $include_details,

        # Device Group
        [Parameter()]
        [Alias("Group")]
        [string]
        $Device_group,

        # Optional Device_Status parameter
        [Parameter()]
        [Alias("DeviceStatus")]
        [ValidateSet("SECURE", "AT_RISK", "COMPROMISED", "NOT_COMPUTED")]
        $Device_status,

        # Optional Device_Type parameter
        [Parameter()]
        [Alias("DeviceType")]
        [ValidateSet("WORKSTATION", "SERVER", "MOBILE")]
        $Device_type,

        # Optional Client_version parameter
        [Parameter()]
        [Alias("ClientVersion")]
        [string]
        $Client_version,

        # Optional edr_enabled parameter
        [Parameter()]
        [Alias("EdrEnabled")]
        [switch]
        $edr_enabled,

        # Optional IPv4 parameter
        [Parameter()]
        [Alias("IPv4")]
        [string]
        $ipv4_address
    )

    begin {
        # Init
        $BaseURL = $($script:configuration.BaseURL)
        $URI = 'https://' + $BaseURL + "/v1/devices"
        $Token = (Get-SEPCloudToken).Token_Bearer
    }

    process {
        $ArrayResponse = @()
        $queryStrings = @{}

        # Iterating through all parameters and add them to the queryParams hashtable
        switch ($PSBoundParameters.Keys) {
            Computername {
                $queryStrings.Add("name", "$Computername")
            }
            is_online {
                $queryStrings.Add("is_online", "true")
            }
            include_details {
                $queryStrings.Add("include_details", "true")
            }
            edr_enabled {
                $queryStrings.Add("edr_enabled", "true")
            }
            Device_status {
                $queryStrings.Add("device_status", "$Device_status")
            }
            Device_type {
                $queryStrings.Add("device_type", "$Device_type")
            }
            Client_version {
                $queryStrings.Add("client_version", "$Client_version")
            }
            Device_group {
                $queryStrings.Add("device_group", "$Device_group")
            }
            ipv4_address {
                $queryStrings.Add("ipv4_address", "$IP_v4")
            }
            Default {}
        }

        # try {
        $params = @{
            Method       = 'GET'
            Uri          = $uri
            Headers      = @{
                Host           = $baseUrl
                Accept         = "application/json"
                Authorization  = $token
                "Content-Type" = "application/json"
            }
            queryStrings = $queryStrings
        }

        $response = Invoke-SEPCloudWebRequest @params #TODO query fails, to be investigated
        $ArrayResponse += $response.devices
        $deviceCount = (($ArrayResponse | Measure-Object).count)

        # If pagination
        if ($response.total -gt $deviceCount) {
            # Loop through via Offset parameter as there is no "next" parameter for /devices/ API call
            do {
                # change the "offset" parameter for next query
                $queryStrings.Remove("offset")
                $queryStrings.Add("offset", $deviceCount)

                # Run query, add it to the array, increment counter
                $response = Invoke-SEPCloudWebRequest @params
                $ArrayResponse += $response.devices
                $deviceCount = (($ArrayResponse | Measure-Object).count)
            } until (
                $deviceCount -ge $response.total
            )
        }

        return $ArrayResponse
    }
}
