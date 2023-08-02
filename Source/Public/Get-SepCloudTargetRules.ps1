function Get-SepCloudTargetRules {
    # TODO to finish; test cmd-let

    begin {
        # Init
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $URI_Tokens = 'https://' + $BaseURL + "/v1/policies/target-rules"
        $Token = Get-SEPCloudToken
        $Body = @{}
        $Headers = @{
            Host          = $BaseURL
            Accept        = "application/json"
            Authorization = $Token
            Body          = $Body
        }
    }

    process {
        # Another fake comment
        # And another one
        try {
            $Response = Invoke-RestMethod -Method GET -Uri $URI_Tokens -Headers $Headers -Body $Body -UseBasicParsing
        }

        catch {
            $StatusCode = $_
            $StatusCode
        }

        $Response
    }
}
