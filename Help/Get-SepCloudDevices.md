---
external help file: PSSymantecCloud-help.xml
Module Name: PSSymantecCloud
online version:
schema: 2.0.0
---

# Get-SEPCloudDevice

## SYNOPSIS
Gathers list of devices from the SEP Cloud console

## SYNTAX

```
Get-SEPCloudDevice [[-Computername] <String>] [-is_online] [-include_details] [[-Device_group] <String>]
 [[-Device_status] <Object>] [[-Device_type] <Object>] [[-Client_version] <String>] [-edr_enabled]
 [[-ipv4_address] <String>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
Get-SEPCloudDevice
Get all devices (very slow)
```

### EXAMPLE 2
```
Get-SEPCloudDevice -Computername MyComputer
Get detailed information about a computer
```

### EXAMPLE 3
```
"MyComputer" | Get-SEPCloudDevice
Get detailed information about a computer
```

### EXAMPLE 4
```
Get-SEPCloudDevice -Online -Device_status AT_RISK
Get all online devices with AT_RISK status
```

### EXAMPLE 5
```
Get-SEPCloudDevice -group "Aw7oerlBROSIl9O_IPFewx"
Get all devices in a device group
```

### EXAMPLE 6
```
Get-SEPCloudDevice -Client_version "14.3.9681.7000" -Device_type WORKSTATION
Get all workstations with client version 14.3.9681.7000
```

### EXAMPLE 7
```
Get-SEPCloudDevice -EdrEnabled -Device_type SERVER
Get all servers with EDR enabled
```

### EXAMPLE 8
```
Get-SEPCloudDevice -IPv4 "192.168.1.1"
Get all devices with IPv4 address
```

## PARAMETERS

### -Client_version
Optional Client_version parameter

```yaml
Type: String
Parameter Sets: (All)
Aliases: ClientVersion

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Computername
Specify one or many computer names.
Accepts pipeline input
Supports partial match

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Device_group
Specify a device group ID to lookup.
Accepts only device group ID, no group name

```yaml
Type: String
Parameter Sets: (All)
Aliases: Group

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Device_status
Lookup devices per security status.
Accepts only "SECURE", "AT_RISK", "COMPROMISED", "NOT_COMPUTED"

```yaml
Type: Object
Parameter Sets: (All)
Aliases: DeviceStatus

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Device_type
Optional Device_Type parameter

```yaml
Type: Object
Parameter Sets: (All)
Aliases: DeviceType

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -edr_enabled
Optional edr_enabled parameter

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: EdrEnabled

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -include_details
Switch to include details in the output

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Details

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ipv4_address
Optional IPv4 parameter

```yaml
Type: String
Parameter Sets: (All)
Aliases: IPv4

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -is_online
Switch to lookup only online machines

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Online

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
