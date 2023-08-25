---
external help file: PSSymantecCloud-help.xml
Module Name: PSSymantecCloud
online version:
schema: 2.0.0
---

# Get-SEPCloudToken

## SYNOPSIS
Generates an authenticated Token from the SEP Cloud API

## SYNTAX

```
Get-SEPCloudToken [[-ClientID] <String>] [[-Secret] <String>] [<CommonParameters>]
```

## DESCRIPTION
Gathers Bearer Token from the SEP Cloud console to interact with the authenticated API
Securely stores credentials or valid token locally (By default on TEMP location)
Connection information available here : https://sep.securitycloud.symantec.com/v2/integration/client-applications

## EXAMPLES

### EXAMPLE 1
```
Get-SEPCloudToken
```

### EXAMPLE 2
```
Get-SEPCloudToken(ClientID,Secret)
```

## PARAMETERS

### -ClientID
ClientID parameter required to generate a token

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Secret
Secret parameter required in combinaison to ClientID to generate a token

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Function logic
1.
Test locally stored encrypted token
2.
Test locally stored encrypted Client/Secret to generate a token
3.
Requests Client/Secret to generate token

## RELATED LINKS
