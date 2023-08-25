---
external help file: PSSymantecCloud-help.xml
Module Name: PSSymantecCloud
online version:
schema: 2.0.0
---

# Get-SepCloudDeviceDetails

## SYNOPSIS
Gathers device details from the SEP Cloud console

## SYNTAX

### Computername (Default)
```
Get-SepCloudDeviceDetails [-Computername <String>] [<CommonParameters>]
```

### Device_ID
```
Get-SepCloudDeviceDetails [-Device_ID <String>] [<CommonParameters>]
```

## DESCRIPTION
Gathers device details from the SEP Cloud console

## EXAMPLES

### EXAMPLE 1
```
Get-SepCloudDeviceDetails -id wduiKXDDSr2CVrRaqrFKNx
```

### EXAMPLE 2
```
Get-SepCloudDeviceDetails -computername MyComputer
```

## PARAMETERS

### -Computername
Computername used to lookup a unique computer

```yaml
Type: String
Parameter Sets: Computername
Aliases: Computer, Device, Hostname, Host

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Device_ID
id used to lookup a unique computer

```yaml
Type: String
Parameter Sets: Device_ID
Aliases: id

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Device_ID
### Computername
## OUTPUTS

### PSObject
## NOTES

## RELATED LINKS
