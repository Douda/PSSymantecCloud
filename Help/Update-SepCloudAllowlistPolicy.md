---
external help file: PSSymantecCloud-help.xml
Module Name: PSSymantecCloud
online version:
schema: 2.0.0
---

# Update-SepCloudAllowlistPolicy

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### ByExcelFileLatestVersion (Default)
```
Update-SepCloudAllowlistPolicy -Policy_Name <String> -excel_path <String> [<CommonParameters>]
```

### ByHashVersionSpecific
```
Update-SepCloudAllowlistPolicy -Policy_Version <String> -Policy_Name <String> [-Add] [-Remove] -sha2 <String>
 -file_name <String> [<CommonParameters>]
```

### ByExcelFileVersionSpecific
```
Update-SepCloudAllowlistPolicy -Policy_Version <String> -Policy_Name <String> -excel_path <String>
 [<CommonParameters>]
```

### ByHashLatestVersion
```
Update-SepCloudAllowlistPolicy -Policy_Name <String> [-Add] [-Remove] -sha2 <String> -file_name <String>
 [<CommonParameters>]
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

### -Add
{{ Fill Add Description }}

```yaml
Type: SwitchParameter
Parameter Sets: ByHashVersionSpecific, ByHashLatestVersion
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -excel_path
{{ Fill excel_path Description }}

```yaml
Type: String
Parameter Sets: ByExcelFileLatestVersion, ByExcelFileVersionSpecific
Aliases: Excel

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -file_name
{{ Fill file_name Description }}

```yaml
Type: String
Parameter Sets: ByHashVersionSpecific, ByHashLatestVersion
Aliases: name

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Policy_Name
{{ Fill Policy_Name Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: PolicyName

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Policy_Version
{{ Fill Policy_Version Description }}

```yaml
Type: String
Parameter Sets: ByHashVersionSpecific, ByExcelFileVersionSpecific
Aliases: Version

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Remove
{{ Fill Remove Description }}

```yaml
Type: SwitchParameter
Parameter Sets: ByHashVersionSpecific, ByHashLatestVersion
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -sha2
{{ Fill sha2 Description }}

```yaml
Type: String
Parameter Sets: ByHashVersionSpecific, ByHashLatestVersion
Aliases: hash

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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
