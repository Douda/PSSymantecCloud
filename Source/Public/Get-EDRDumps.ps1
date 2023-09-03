function Get-EDRDumps {

    <# TODO write help
    .SYNOPSIS
        Gets a list of the SEP Cloud Commands
    .DESCRIPTION
        Gets a list of the SEP Cloud Commands. All commands are returned by default.
    .EXAMPLE
        Get-SepCloudCommands

        Gets a list of the SEP Cloud Commands
    #>

    begin {
        # Init
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $Token = (Get-SEPCloudToken).Token_Bearer
    }

    process {
        #TODO add command_id by using get-SepCloudCommands
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
