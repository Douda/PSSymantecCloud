---
external help file: PSSymantecCloud-help.xml
Module Name: PSSymantecCloud
online version:
schema: 2.0.0
---

# Export-SepCloudDenyListPolicyToExcel

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### PolicyName (Default)
```
Export-SepCloudDenyListPolicyToExcel -excel_path <String> [-Policy_Version <String>] [-Policy_Name <String>]
 [<CommonParameters>]
```

### PolicyObj
```
Export-SepCloudDenyListPolicyToExcel -excel_path <String> [-Policy_Version <String>] [-Policy_Name <String>]
 [-obj_policy <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -excel_path
{{ Fill excel_path Description }}

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
{{ Fill obj_policy Description }}

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
{{ Fill Policy_Name Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: Name

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Policy_Version
{{ Fill Policy_Version Description }}

```yaml
Type: String
Parameter Sets: (All)
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

### System.Management.Automation.PSObject

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
