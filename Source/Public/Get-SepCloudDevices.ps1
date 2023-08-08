function Get-SepCloudDevices {
    <#
    .SYNOPSIS
        Gathers list of devices from the SEP Cloud console
    .PARAMETER Computername
    Specify one or many computer names. Accepts pipeline (up to 10 devices per query)
    Supports partial match
    .PARAMETER is_online
    Switch to lookup only online machines
    .PARAMETER Device_status
    Lookup devices per security status. Accepts only "SECURE", "AT_RISK", "COMPROMISED", "NOT_COMPUTED"
    .EXAMPLE
    Get-SepCloudDevices
    .EXAMPLE
    Get-SepCloudDevices -Computername MyComputer
    .EXAMPLE
    Get-SepCloudDevices -is_online -Device_status AT_RISK
    .EXAMPLE
    Get-SepCloudDevices -group "Aw7oerlBROSIl9O_IPFewx"
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
        $Device_status
    )

    begin {
        # Init
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $URI_Tokens = 'https://' + $BaseURL + "/v1/devices"
        $ArrayResponse = @()
        $Token = Get-SEPCloudToken
    }

    process {

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
            Device_status {
                $Body.Add("device_status", "$Device_status")
            }
            Device_group {
                $Body.Add("device_group", "$Device_group")
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
            $Response = Invoke-RestMethod -Method GET -Uri $URI_Tokens -Headers $Headers -Body $Body -UseBasicParsing
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
                    $Response = Invoke-RestMethod -Method GET -Uri $URI_Tokens -Headers $Headers -Body $Body -UseBasicParsing
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
