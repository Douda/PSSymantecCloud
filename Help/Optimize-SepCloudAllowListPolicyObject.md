---
external help file: PSSymantecCloud-help.xml
Module Name: PSSymantecCloud
online version:
schema: 2.0.0
---

# Optimize-SepCloudAllowListPolicyObject

## SYNOPSIS
Removes empty properties from the SEP Cloud Allow List Policy Object

## SYNTAX

```
Optimize-SepCloudAllowListPolicyObject [-obj] <PSObject> [<CommonParameters>]
```

## DESCRIPTION
Removes empty properties from the SEP Cloud Allow List Policy Object.
This is required to avoid errors when creating a new policy.

## EXAMPLES

### EXAMPLE 1
```
$AllowListPolicyOptimized = $AllowListPolicy | Optimize-SepCloudAllowListPolicyObject
```

## PARAMETERS

### -obj
{{ Fill obj Description }}

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

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
