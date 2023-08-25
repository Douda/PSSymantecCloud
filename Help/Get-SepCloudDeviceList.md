---
external help file: PSSymantecCloud-help.xml
Module Name: PSSymantecCloud
online version:
schema: 2.0.0
---

# Get-SepCloudDeviceList

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
Get-SepCloudDeviceList [[-Computername] <String>] [-is_online] [-include_details] [[-Device_group] <String>]
 [[-Device_status] <Object>] [<CommonParameters>]
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

### -Computername
{{ Fill Computername Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Device_group
{{ Fill Device_group Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: Group

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Device_status
{{ Fill Device_status Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases: DeviceStatus
Accepted values: SECURE, AT_RISK, COMPROMISED, NOT_COMPUTED

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -include_details
{{ Fill include_details Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Details

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -is_online
{{ Fill is_online Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Online

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
