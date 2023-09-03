---
external help file: PSSymantecCloud-help.xml
Module Name: PSSymantecCloud
online version:
schema: 2.0.0
---

# Get-SepCloudEventSearch

## SYNOPSIS
Get list of SEP Cloud Events.
By default it will gather data for past 30 days

## SYNTAX

### Query (Default)
```
Get-SepCloudEventSearch [-Query <String>] [-PastDays <Int32>] [<CommonParameters>]
```

### FileDetection
```
Get-SepCloudEventSearch [-FileDetection] [-PastDays <Int32>] [<CommonParameters>]
```

### FullScan
```
Get-SepCloudEventSearch [-FullScan] [-PastDays <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Get list of SEP Cloud Events.
You can use the following parameters to filter the results: FileDetection, FullScan, or a custom Lucene query

## EXAMPLES

### EXAMPLE 1
```
Get-SepCloudEventSearch
Gather all possible events. ** very slow approach & limited to 10k events **
```

### EXAMPLE 2
```
Get-SepCloudEventSearch -FileDetection -pastdays 20
Gather all file detection events for the past 20 days
```

### EXAMPLE 3
```
Get-SepCloudEventSearch -FullScan
Gather all full scan events
```

### EXAMPLE 4
```
Get-SepCloudEventSearch -Query "type_id:8031 OR type_id:8032 OR type_id:8033"
Runs a custom Lucene query
```

### EXAMPLE 5
```
Get-SepCloudEventSearch -Query "type_id:8031 OR type_id:8032 OR type_id:8033" -PastDays 14
Runs a custom Lucene query for the past 14 days
```

## PARAMETERS

### -FileDetection
Runs the following Lucene query "feature_name:MALWARE_PROTECTION AND ( type_id:8031 OR type_id:8032 OR type_id:8033 OR type_id:8027 OR type_id:8028 ) AND ( id:12 OR id:11 AND type_id:8031 )"

```yaml
Type: SwitchParameter
Parameter Sets: FileDetection
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -FullScan
Runs the following Lucene query "Event Type Id:8020-Scan AND Scan Name:Full Scan"

```yaml
Type: SwitchParameter
Parameter Sets: FullScan
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PastDays
Number of days to go back in the past.
Default is 29 days

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: Days

Required: False
Position: Named
Default value: 29
Accept pipeline input: False
Accept wildcard characters: False
```

### -Query
Runs a custom Lucene query

```yaml
Type: String
Parameter Sets: Query
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

### [string] Query
### [int] PastDays
### [switch] FileDetection
### [switch] FullScan
## OUTPUTS

### [PSCustomObject] Events
## NOTES

## RELATED LINKS
