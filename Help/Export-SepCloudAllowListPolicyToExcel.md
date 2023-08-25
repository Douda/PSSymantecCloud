---
external help file: PSSymantecCloud-help.xml
Module Name: PSSymantecCloud
online version:
schema: 2.0.0
---

# Export-SepCloudAllowListPolicyToExcel

## SYNOPSIS
Export an Allow List policy to a human readable excel report

## SYNTAX

### PolicyName (Default)
```
Export-SepCloudAllowListPolicyToExcel -excel_path <String> [-Policy_Version <String>] [-Policy_Name <String>]
 [<CommonParameters>]
```

### PolicyObj
```
Export-SepCloudAllowListPolicyToExcel -excel_path <String> [-obj_policy <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Exports an allow list policy object it to an Excel file, with one tab per allow type (filename/file hash/directory etc...)
Supports pipeline input with allowlist policy object

## EXAMPLES

### EXAMPLE 1
```
Export-SepCloudAllowListPolicyToExcel -Name "My Allow list Policy" -Version 1 -Path "allow_list.xlsx"
Exports the policy with name "My Allow list Policy" and version 1 to an excel file named "allow_list.xlsx"
```

### EXAMPLE 2
```
Get-SepCloudPolicyDetails -Name "My Allow list Policy" | Export-SepCloudAllowListPolicyToExcel -Path "allow_list.xlsx"
Gathers policy in an object, pipes the output to Export-SepCloudAllowListPolicyToExcel to export in excel format
```

## PARAMETERS

### -excel_path
Path of Export

```yaml
Type: String
Parameter Sets: (All)
Aliases: Excel, Path

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -obj_policy
Policy Obj to work with

```yaml
Type: PSObject
Parameter Sets: PolicyObj
Aliases: PolicyObj

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Policy_Name
Exact policy name

```yaml
Type: String
Parameter Sets: PolicyName
Aliases: Name

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Policy_Version
Policy version

```yaml
Type: String
Parameter Sets: PolicyName
Aliases: Version

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Policy name
### Policy version
### Excel path
## OUTPUTS

### Excel file
## NOTES

## RELATED LINKS
