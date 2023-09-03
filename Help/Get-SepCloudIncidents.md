---
external help file: PSSymantecCloud-help.xml
Module Name: PSSymantecCloud
online version:
schema: 2.0.0
---

# Get-SepCloudIncidents

## SYNOPSIS
Get list of SEP Cloud incidents.
By default, shows only opened incidents

## SYNTAX

### QueryOpen (Default)
```
Get-SepCloudIncidents [-Open] [-Include_events] [<CommonParameters>]
```

### QueryCustom
```
Get-SepCloudIncidents [-Include_events] [-Query <String>] [<CommonParameters>]
```

## DESCRIPTION
Get list of SEP Cloud incidents.
Using the LUCENE query syntax, you can customize which incidents to gather.
More information : https://techdocs.broadcom.com/us/en/symantec-security-software/endpoint-security-and-management/endpoint-security/sescloud/Endpoint-Detection-and-Response/investigation-page-overview-v134374740-d38e87486/Cloud-Database-Search/query-and-filter-operators-by-data-type-v134689952-d38e88796.html

## EXAMPLES

### EXAMPLE 1
```
Get-SepCloudIncidents -Open -Include_Events
```

### EXAMPLE 2
```
Get-SepCloudIncidents -Query "state_id: [0 TO 5]"
This query a list of every possible incidents (opened, closed and with "Unknown" status)
```

## PARAMETERS

### -Include_events
Includes every events that both are part of the context & triggered incident events

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Open
filters only opened incidents.
Simulates a query "state_id: \[0 TO 3\]" which represents incidents with the following states \<0 Unknown | 1 New | 2 In Progress | 3 On Hold\>

```yaml
Type: SwitchParameter
Parameter Sets: QueryOpen
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Query
Custom Lucene query to pass to the API

```yaml
Type: String
Parameter Sets: QueryCustom
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### PSObject containing all SEP incidents
## NOTES

## RELATED LINKS
