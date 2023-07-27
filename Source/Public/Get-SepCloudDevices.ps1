function Get-SepCloudDevices {
    <# TODO fill up description
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
    #>

    [CmdletBinding()]
    param (
        <# Optional ComputerName parameter
        TODO work to allow multiple values from Computername
        More info https://apidocs.securitycloud.symantec.com/#
        name	query	name of the device. [NOTE] Provide comma seperated values in case of multiple name search
        Note : seems to be limited to 10 values max
        #>
        [Parameter(
            ValueFromPipeline = $true
        )]
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
    }

    process {
        # Get token
        $Token = Get-SEPCloudToken

        if ($null -ne $Token ) {
            # HTTP body content containing all the queries
            $Body = @{}

            # Iterating through all parameter and add them to the HTTP body
            if ($Computername -ne "") {
                $Body.Add("name", "$Computername")
            }
            if ($is_online -eq $true ) {
                $body.add("is_online", "true")
            }
            if ($include_details -eq $true) {
                $Body.Add("include_details", "true")
            }
            if ($Device_status -ne "") {
                $Body.Add("device_status", "$Device_status")
            }
            if ($Device_group -ne "") {
                $Body.Add("device_group", "$Device_group")
            }
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
        }
    }

    end {
        return $ArrayResponse
    }
}
