---
external help file: PSSymantecCloud-help.xml
Module Name: PSSymantecCloud
online version:
schema: 2.0.0
---

# Get-SepThreatIntelCveProtection

## SYNOPSIS
Provide information whether a given CVE has been blocked by any of Symantec technologies

## SYNTAX

```
Get-SepThreatIntelCveProtection [-cve] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Provide information whether a given URL/domain has been blocked by any of Symantec technologies.
These technologies include Antivirus (AV), Intrusion Prevention System (IPS) and Behavioral Analysis & System Heuristics (BASH)

## EXAMPLES

### EXAMPLE 1
```
Get-SepThreatIntelCveProtection -cve CVE-2023-35311
Gathers information whether CVE-2023-35311 has been blocked by any of Symantec technologies
```

### EXAMPLE 2
```
"CVE-2023-35311","CVE-2023-35312" | Get-SepThreatIntelCveProtection
Gathers cve from pipeline by value whether CVE-2023-35311 & CVE-2023-35312 have been blocked by any of Symantec technologies
```

## PARAMETERS

### -cve
Specify one or many CVE to check

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: vuln, vulnerability

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

## NOTES

## RELATED LINKS
