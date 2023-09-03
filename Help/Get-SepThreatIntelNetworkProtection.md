---
external help file: PSSymantecCloud-help.xml
Module Name: PSSymantecCloud
online version:
schema: 2.0.0
---

# Get-SepThreatIntelNetworkProtection

## SYNOPSIS
Provide information whether a given URL/domain has been blocked by any of Symantec technologies

## SYNTAX

```
Get-SepThreatIntelNetworkProtection [-network] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Provide information whether a given URL/domain has been blocked by any of Symantec technologies.
These technologies include Antivirus (AV), Intrusion Prevention System (IPS) and Behavioral Analysis & System Heuristics (BASH)

## EXAMPLES

### EXAMPLE 1
```
Get-SepThreatIntelNetworkProtection -domain nicolascoolman.eu
Gathers information whether the URL/domain has been blocked by any of Symantec technologies
```

### EXAMPLE 2
```
"nicolascoolman.eu","google.com" | Get-SepThreatIntelNetworkProtection
Gathers somains from pipeline by value whether the URLs/domains have been blocked by any of Symantec technologies
```

## PARAMETERS

### -network
Mandatory domain name

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: domain, url

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSObject
## NOTES

## RELATED LINKS
