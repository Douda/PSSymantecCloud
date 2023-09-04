function Get-SepCloudFilesInfo {

    <#
    .SYNOPSIS
        Gets information about a specific file hash and devices seen on
    .DESCRIPTION
        Gets information about a specific file hash and devices seen on
    .EXAMPLE
        Get-SepCloudFilesInfo -FileHash 423b212eab8073b53c46522ee2e2a5f14ffe090b5835f385b9818b08c242c2b6

        Gets information about a specific file hash and provides amount of devices seen on
        C:\PSSymantecCloud> $test

        most_prevalent_file_name : relog.exe
        folders                  : {C:\Windows\WinSxS\wow64_microsoft-windows-p..ncetoolscommandline_31bf3856ad364e35_10.0.19041.546_none_49716c2392052aca\r,
                                    C:\Windows\servicing\LCU\Package_for_RollupFix~31bf3856ad364e35~amd64~~19041.1706.1.7\wow64_microsoft-windows-p..ncetoolscommandline_31bf3856ad364e35_10.0.19041.546_none_49716c2392052aca\r,
                                    C:\Windows\servicing\LCU\Package_for_RollupFix~31bf3856ad364e35~amd64~~19041.1645.1.11\wow64_microsoft-windows-p..ncetoolscommandline_31bf3856ad364e35_10.0.19041.546_none_49716c2392052aca\r }
        file_hash                : 423b212eab8073b53c46522ee2e2a5f14ffe090b5835f385b9818b08c242c2b6
        risk                     : VERY_LOW
        certificate_signer       : Unsigned
        devices_seen_on          : 891
        first_seen               : 20/10/2021 14:09:45
        last_action              : 02/04/2022 13:31:29
        reputation               : GOOD
        prevalence               : VERY_FEW_USERS
        global_prevalence        : MANY_USERS
        file_size                : 177
        hidden                   : False
        policies                 : {}

    .EXAMPLE
        Get-SepCloudFilesInfo -FileHash 1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef -IncludeDevices

        Gets information about a specific file hash and provides list and details of devices seen on
    #>
    [CmdletBinding()]
    param (
        # devices switch
        [switch]
        $IncludeDevices,

        # file hash string
        [string]
        $FileHash
    )

    begin {
        # Init
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $Token = (Get-SEPCloudToken).Token_Bearer
        $Headers = @{
            Host           = $BaseURL
            Accept         = "application/json"
            "Content-Type" = "application/json"
            Authorization  = $Token
        }
    }

    process {
        $URI_File_Hash_Details = 'https://' + $BaseURL + "/v1/files/" + $FileHash
        $URI_Devices_Seen_On = 'https://' + $BaseURL + "/v1/files/" + $FileHash + "/devices"

        # Devices seen on
        # If the devices switch is enabled
        if ($IncludeDevices) {
            # Init
            $allResults = @()

            # URI parameters
            $pageOffset = 0
            $limit = 500

            do {
                try {
                    $params = @{
                        Uri             = $URI_Devices_Seen_On + "?pageOffset=$pageOffset&limit=$limit"
                        Method          = 'GET'
                        Headers         = $Headers
                        UseBasicParsing = $true
                    }

                    $Resp = Invoke-RestMethod @params
                    $allResults += $Resp.devices
                    $pageOffset++
                } catch {
                    Write-Warning -Message "Error: $_"
                }
            } until ($allResults.count -eq $Resp.total)
            return $allResults
        }

        # File hash info (without devices details)
        if (-not $IncludeDevices) {
            do {
                try {
                    $params = @{
                        Uri             = $URI_File_Hash_Details
                        Method          = 'GET'
                        Headers         = $Headers
                        UseBasicParsing = $true
                    }

                    $Resp = Invoke-RestMethod @params
                } catch {
                    Write-Warning -Message "Error: $_"
                }

            } until ($null -eq $resp.next)
            return $Resp
        }
    }
}
