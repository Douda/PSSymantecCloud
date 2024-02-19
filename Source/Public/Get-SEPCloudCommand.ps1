function Get-SEPCloudCommand {

    <# TODO write help
    .SYNOPSIS
        Gets a list of the SEP Cloud Commands
    .DESCRIPTION
        Gets a list of the SEP Cloud Commands. All commands are returned by default.
    .EXAMPLE
        Get-SEPCloudCommand

        Gets a list of the SEP Cloud Commands
    #>

    begin {
        # Init
        $BaseURL = $($script:configuration.BaseURL)
        $Token = (Get-SEPCloudToken).Token_Bearer
    }

    process {
        $URI = 'https://' + $BaseURL + "/v1/commands/endpoint-search"
        $allResults = @()
        $body = @{
            query = ""
            next  = 0
        }
        $Headers = @{
            Host           = $BaseURL
            Accept         = "application/json"
            "Content-Type" = "application/json"
            Authorization  = $Token
        }

        do {
            try {
                $params = @{
                    Uri             = $URI
                    Method          = 'POST'
                    Body            = $Body | ConvertTo-Json
                    Headers         = $Headers
                    UseBasicParsing = $true
                }

                $Resp = Invoke-RestMethod @params
                $allResults += $Resp.commands
                $body.next = $Resp.next
            } catch {
                Write-Warning -Message "Error: $_"
            }

        } until ($null -eq $resp.next)

        return $allResults
    }
}
