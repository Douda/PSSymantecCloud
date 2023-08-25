---
external help file: PSSymantecCloud-help.xml
Module Name: PSSymantecCloud
online version:
schema: 2.0.0
---

# Merge-SepCloudAllowList

## SYNOPSIS
Merges 2 SEP Cloud allow list policy to a single PSObject

## SYNTAX

```
Merge-SepCloudAllowList [[-Policy_Version] <String>] [-Policy_Name] <String> [-excel_path] <String>
 [<CommonParameters>]
```

## DESCRIPTION
Returns a custom PSObject ready to be converted in json as HTTP Body for Update-SepCloudAllowlistPolicy CmdLet
Excel file takes precedence in case of conflicts.
It is the main "source of truth".
Logic goes as below
- If SEP exception present in both excel & policy : no changes
- If SEP exception present only in Excel : add exception
- If SEP exception present only in policy (so not in Excel) : remove exception

## EXAMPLES

### EXAMPLE 1
```
Merge-SepCloudAllowList -Policy_Name "My Allow List Policy For Servers" -Excel ".\Data\Centralized_exceptions_for_servers.xlsx" | Update-SepCloudAllowlistPolicy
```

## PARAMETERS

### -excel_path
excel path

```yaml
Type: String
Parameter Sets: (All)
Aliases: Excel, Path

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Policy_Name
Exact policy name

```yaml
Type: String
Parameter Sets: (All)
Aliases: PolicyName

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Policy_Version
Policy version

```yaml
Type: String
Parameter Sets: (All)
Aliases: Version

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### - SEP cloud allow list policy PSObject
### - Excel report file path (previously generated from Export-SepCloudAllowListPolicyToExcel CmdLet)
## OUTPUTS

### - Custom PSObject
## NOTES
Excel file takes precedence in case of conflicts

## RELATED LINKS
