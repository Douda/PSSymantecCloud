function Get-SepCloudDevices {
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
    Get-SepCloudDevices
    Get all devices (very slow)
    .EXAMPLE
    Get-SepCloudDevices -Computername MyComputer
    Get detailed information about a computer
    .EXAMPLE
    "MyComputer" | Get-SepCloudDevices
    Get detailed information about a computer
    .EXAMPLE
    Get-SepCloudDevices -Online -Device_status AT_RISK
    Get all online devices with AT_RISK status
    .EXAMPLE
    Get-SepCloudDevices -group "Aw7oerlBROSIl9O_IPFewx"
    Get all devices in a device group
    .EXAMPLE
    Get-SepCloudDevices -Client_version "14.3.9681.7000" -Device_type WORKSTATION
    Get all workstations with client version 14.3.9681.7000
    .EXAMPLE
    Get-SepCloudDevices -EdrEnabled -Device_type SERVER
    Get all servers with EDR enabled
    .EXAMPLE
    Get-SepCloudDevices -IPv4 "192.168.1.1"
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
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $URI = 'https://' + $BaseURL + "/v1/devices"
        $Token = (Get-SEPCloudToken).Token_Bearer
    }

    process {
        $ArrayResponse = @()
        # HTTP body content containing all the queries
        $Body = @{}

        # Iterating through all parameters and add them to the HTTP body
        switch ($PSBoundParameters.Keys) {
            Computername {
                $Body.Add("name", "$Computername")
            }
            is_online {
                $Body.Add("is_online", "true")
            }
            include_details {
                $Body.Add("include_details", "true")
            }
            edr_enabled {
                $Body.Add("edr_enabled", "true")
            }
            Device_status {
                $Body.Add("device_status", "$Device_status")
            }
            Device_type {
                $Body.Add("device_type", "$Device_type")
            }
            Client_version {
                $Body.Add("client_version", "$Client_version")
            }
            Device_group {
                $Body.Add("device_group", "$Device_group")
            }
            ipv4_address {
                $Body.Add("ipv4_address", "$IP_v4")
            }
            Default {}
        }

        # Setup Headers
        $Headers = @{
            Host          = $BaseURL
            Accept        = "application/json"
            Authorization = $Token
        }

        try {
            $params = @{
                Uri             = $URI
                Method          = 'GET'
                Body            = $Body
                Headers         = $Headers
                UseBasicParsing = $true
            }

            # Run query, add it to the array, increment counter
            $Response = Invoke-RestMethod @params
            $ArrayResponse += $Response.devices
            $Devices_count_gathered = (($ArrayResponse | Measure-Object).count)
            <# If pagination #>
            if ($Response.total -gt $Devices_count_gathered) {
                <# Loop through via Offset parameter as there is no "next" parameter for /devices/ API call #>
                do {
                    # change the "offset" parameter for next query
                    $Body.Remove("offset")
                    $Body.Add("offset", $Devices_count_gathered)
                    # Run query, add it to the array, increment counter
                    $Response = Invoke-RestMethod @params
                    $ArrayResponse += $Response.devices
                    $Devices_count_gathered = (($ArrayResponse | Measure-Object).count)
                } until (
                    $Devices_count_gathered -ge $Response.total
                )
            }

        } catch {
            $StatusCode = $_
            $StatusCode
        }

        return $ArrayResponse
    }
}
