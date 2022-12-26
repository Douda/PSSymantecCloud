function Export-SepCloudPolicyToExcel {
    <# TODO fill description
    .SYNOPSIS
        Export an Allow List policy object to a human readable excel report
    .INPUTS
        Clean policy object from Sep-SepCloudPolicyDetails function
    .OUTPUTS
        Excel file
    .DESCRIPTION
        Takes an allow list policy object as input and exports it to an Excel file, with one tab per allow type (filename/file hash/directory etc...)
    .EXAMPLE
        Get-SepCloudPolicyDetails -Name "My Allow list Policy" | Export-SepCloudPolicyToExcel -Path "allow_list.xlsx"
        Gathers policy in an object, pipes the output to Export-SepCloudPolicyToExcel
    #>

    param (
        # Path of Export
        [Parameter()]
        [Alias("Path")]
        [Alias("Excel")]
        [string]
        $excel_path,

        # Policy Obj to work with
        [Parameter(
            ValueFromPipeline,
            Mandatory
        )]
        [pscustomobject]
        $obj_policy
    )
    <#
    Using as a template the following command
    Get-SepCloudPolicyDetails -Name "MyAllowListPolicy" -Policy_version 1 | Export-SepCloudPolicyToExcel -Path "C:\Test\test5.xlsx"
    Parsing the custom object to get the list of
    $obj_policy.features.configuration.applications
    $obj_policy.features.configuration.applications.processfile
    $obj_policy.features.configuration.applications.processfile.name
    $obj_policy.features.configuration.applications.processfile.sha2
    $obj_policy.features.configuration.certificates
    $obj_policy.features.configuration.webdomains
    $obj_policy.features.configuration.ips_hosts
    $obj_policy.features.configuration.extensions
    $obj_policy.features.configuration.extensions.names
    $obj_policy.features.configuration.windows.files
    $obj_policy.features.configuration.windows.directories
    #>

    # Init
    $Applications = $obj_policy.features.configuration.applications.processfile
    $Certificates = $obj_policy.features.configuration.certificates
    $Webdomains = $obj_policy.features.configuration.webdomains
    $Ips_Hosts = $obj_policy.features.configuration.ips_hosts
    $Extensions = $obj_policy.features.configuration.extensions.names
    $Files = $obj_policy.features.configuration.windows.files
    $Directories = $obj_policy.features.configuration.windows.directories

    Import-Module -Name ImportExcel
    $Applications | Export-Excel $excel_path -WorksheetName "Applications" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter
    $Certificates | ConvertTo-FlatObject | Export-Excel $excel_path -WorksheetName "Certificates" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter
    $Webdomains | Export-Excel $excel_path -WorksheetName "Webdomains" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter
    $Ips_Hosts | Export-Excel $excel_path -WorksheetName "Ips_Hosts" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter

    # Extension list comes as an array without name
    # dumping array from row 2 and manually setting colum name in row 1
    $Extensions | Export-Excel $excel_path -WorksheetName "Extensions" -ClearSheet -StartRow 2
    $Excel_imported = Open-ExcelPackage -Path $excel_path
    $Excel_imported.'Extensions'.cells["a1"].Value = 'Extensions'
    Close-ExcelPackage -ExcelPackage $Excel_imported

    $Files | ConvertTo-FlatObject | Export-Excel $excel_path -WorksheetName "Files" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter
    $Directories | ConvertTo-FlatObject | Export-Excel $excel_path -WorksheetName "Directories" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter
}
