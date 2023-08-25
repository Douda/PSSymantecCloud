---
external help file: PSSymantecCloud-help.xml
Module Name: PSSymantecCloud
online version:
schema: 2.0.0
---

# Get-SepThreatIntelFileProtection

## SYNOPSIS
Provide information whether a given file has been blocked by any of Symantec technologies

## SYNTAX

```
Get-SepThreatIntelFileProtection [-file_sha256] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Provide information whether a given file has been blocked by any of Symantec technologies.
These technologies include Antivirus (AV), Intrusion Prevention System (IPS) and Behavioral Analysis & System Heuristics (BASH)

## EXAMPLES

### EXAMPLE 1
```
Get-SepThreatIntelFileProtection -file_sha256 eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d
Gathers information whether the file with sha256 has been blocked by any of Symantec technologies
```

### EXAMPLE 2
```
"eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d","eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8e" | Get-SepThreatIntelFileProtection
Gathers sha from pipeline by value whether the files with sha256 have been blocked by any of Symantec technologies
```

## PARAMETERS

### -file_sha256
Specify one or many sha256 hash

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: sha256

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### sha256
## OUTPUTS

### PSObject
## NOTES

## RELATED LINKS
