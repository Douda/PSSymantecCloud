---
external help file: PSSymantecCloud-help.xml
Module Name: PSSymantecCloud
online version:
schema: 2.0.0
---

# ConvertTo-FlatObject

## SYNOPSIS
Flattends a nested object into a single level object.

## SYNTAX

```
ConvertTo-FlatObject [[-Objects] <Object[]>] [[-Separator] <String>] [[-Base] <Object>] [[-Depth] <Int32>]
 [[-ExcludeProperty] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Flattends a nested object into a single level object.

## EXAMPLES

### EXAMPLE 1
```
$Object3 = [PSCustomObject] @{
    "Name"    = "Przemyslaw Klys"
    "Age"     = "30"
    "Address" = @{
        "Street"  = "Kwiatowa"
        "City"    = "Warszawa"


"Country" = \[ordered\] @{
            "Name" = "Poland"
        }
        List      = @(
            \[PSCustomObject\] @{
                "Name" = "Adam Klys"
                "Age"  = "32"
            }
            \[PSCustomObject\] @{
                "Name" = "Justyna Klys"
                "Age"  = "33"
            }
            \[PSCustomObject\] @{
                "Name" = "Justyna Klys"
                "Age"  = 30
            }
            \[PSCustomObject\] @{
                "Name" = "Justyna Klys"
                "Age"  = $null
            }
        )
    }
    ListTest  = @(
        \[PSCustomObject\] @{
            "Name" = "Sława Klys"
            "Age"  = "33"
        }
    )
}

$Object3 | ConvertTo-FlatObject
```

## PARAMETERS

### -Base
The first index name of an embedded array:
- 1, arrays will be 1 based: \<Parent\>.1, \<Parent\>.2, \<Parent\>.3, …
- 0, arrays will be 0 based: \<Parent\>.0, \<Parent\>.1, \<Parent\>.2, …
- "", the first item in an array will be unnamed and than followed with 1: \<Parent\>, \<Parent\>.1, \<Parent\>.2, …

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -Depth
The maximal depth of flattening a recursive property.
Any negative value will result in an unlimited depth and could cause a infinitive loop.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 5
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeProperty
The propertys to be excluded from the output.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Objects
The object (or objects) to be flatten.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Separator
The separator used between the recursive property names

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: .
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Based on https://powersnippets.com/convertto-flatobject/

## RELATED LINKS
