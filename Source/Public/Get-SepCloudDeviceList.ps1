function Get-SepCloudDeviceList {
    <# TODO fill up description
    .SYNOPSIS
        Gathers list of devices from the SEP Cloud console
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.

    .PARAMETER Computername
    Specify one or many computer names. Accepts pipeline (up to 10 devices per query)
    Supports partial match

    .PARAMETER is_online
    Switch to lookup only online machines

    .PARAMETER Device_status
    Lookup devices per security status. Accepts only "SECURE", "AT_RISK", "COMPROMISED", "NOT_COMPUTED"

    .EXAMPLE
    Get-SepCloudDeviceList

    .EXAMPLE
    Get-SepCloudDeviceList -Computername MyComputer

    .EXAMPLE
    Get-SepCloudDeviceList -is_online -Device_status AT_RISK
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

    # Init
    $BaseURL = (Get-ConfigurationPath).BaseUrl
    $URI_Tokens = 'https://' + $BaseURL + "/v1/devices"
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
            Body          = $Body
        }

        try {
            $Response = Invoke-RestMethod -Method GET -Uri $URI_Tokens -Headers $Headers -Body $Body -UseBasicParsing
            return $Response
        } catch {
            $StatusCode = $_.Exception.Response.StatusCode
            Write-Warning "Query error - Expected HTTP 200, got $([int]$StatusCode)"
        }
    }
}
