---
external help file: PSSymantecCloud-help.xml
Module Name: PSSymantecCloud
online version:
schema: 2.0.0
---

# Get-SepCloudPolicyDetails

## SYNOPSIS
Gathers detailed information on SEP Cloud policy

## SYNTAX

```
Get-SepCloudPolicyDetails [[-Policy_UUID] <String>] [[-Policy_Version] <String>] [-Policy_Name] <String[]>
 [<CommonParameters>]
```

## DESCRIPTION
Gathers detailed information on SEP Cloud policy

## EXAMPLES

### EXAMPLE 1
```
Get-SepCloudPolicyDetails -name "My Policy"
Gathers detailed information on the latest version SEP Cloud policy named "My Policy"
```

### EXAMPLE 2
```
Get-SepCloudPolicyDetails -name "My Policy" -version 1
Gathers detailed information on the version 1 of SEP Cloud policy named "My Policy"
```

### EXAMPLE 3
```
"My Policy","My Policy 2" | Get-SepCloudPolicyDetails
Piped strings are used as policy name to gather detailed information on the latest version SEP Cloud policy named "My Policy" & "My Policy 2"
```

## PARAMETERS

### -Policy_Name
Exact policy name

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Name

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Policy_UUID
Policy UUID

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
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

### System.String[]

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
