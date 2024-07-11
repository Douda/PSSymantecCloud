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

        do {
            try {
                $params = @{
                    Uri     = $URI
                    Method  = 'POST'
                    Body    = @{
                        query = ""
                        # next  = 0
                    }
                    Headers = @{
                        Host           = $BaseURL
                        Accept         = "application/json"
                        "Content-Type" = "application/json"
                        Authorization  = $Token
                    }
                }

                # $Resp = Invoke-RestMethod @params
                $Resp = Invoke-ABWebRequest @params
                $allResults += $Resp.commands
                $body.next = $Resp.next
                # TODO verify the loop works
            } catch {
                Write-Warning -Message "Error: $_"
            }

        } until ($null -eq $resp.next)

        return $allResults
    }
}
