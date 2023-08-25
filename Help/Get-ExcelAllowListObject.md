---
external help file: PSSymantecCloud-help.xml
Module Name: PSSymantecCloud
online version:
schema: 2.0.0
---

# Get-ExcelAllowListObject

## SYNOPSIS
Imports excel allow list report from its file path as a PSObject

## SYNTAX

```
Get-ExcelAllowListObject [[-excel_path] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Imports excel allow list report as a PSObject.
Same structure that Get-SepCloudPolicyDetails uses to compare Excel allow list and SEP Cloud allow list policy

## EXAMPLES

### EXAMPLE 1
```
Get-ExcelAllowListObject -Path "WorkstationsAllowListPolicy.xlsx"
Imports the excel file and returns a structured PSObject
```

## PARAMETERS

### -excel_path
excel path

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Excel, Path

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Excel path of allow list policy previously generated from Export-SepCloudAllowListPolicyToExcel CmdLet
## OUTPUTS

### Custom PSObject
## NOTES

## RELATED LINKS
