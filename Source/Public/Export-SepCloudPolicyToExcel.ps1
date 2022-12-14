function Export-SepCloudPolicyToExcel {
    <#
    .SYNOPSIS
        Export an Allow List policy object to a human readable excel report
    .INPUTS
        Policy object from Get-SepCloudPolicyDetails function. Pipeline support
    .OUTPUTS
        Excel file
    .DESCRIPTION
        Takes an allow list policy object as input and exports it to an Excel file, with one tab per allow type (filename/file hash/directory etc...)
    .EXAMPLE
        Get-SepCloudPolicyDetails -Name "My Allow list Policy" | Export-SepCloudPolicyToExcel -Path "allow_list.xlsx"
        Gathers policy in an object, pipes the output to Export-SepCloudPolicyToExcel to export in excel format
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
    $Extensions = $obj_policy.features.configuration.extensions.names
    $Files = $obj_policy.features.configuration.windows.files
    $Directories = $obj_policy.features.configuration.windows.directories

    # Split IPS ipv4 addresses & subnet in 2 different arrays to export in 2 different excel sheets
    $Ips_Hosts = @()
    $Ips_Hosts_subnet = @()
    $Ips_Hosts_temp = $obj_policy.features.configuration.ips_hosts
    $Ips_Hosts_subnet_temp = $obj_policy.features.configuration.ips_hosts.ipv4_subnet

    # IPS subnets are a part of IPS_host but is showing empty strings
    # adding non empty values to correct arrays
    foreach ($line in $Ips_Hosts_subnet_temp) {
        if ($null -ne $line) {
            $Ips_Hosts_subnet += $line
        }
    }
    foreach ($line in $Ips_Hosts_temp) {
        if ($null -ne $line.ip) {
            $Ips_Hosts += $line
        }
    }

    # Exporting data to Excel
    Import-Module -Name ImportExcel
    $Applications | Export-Excel $excel_path -WorksheetName "Applications" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter
    $Certificates | ConvertTo-FlatObject | Export-Excel $excel_path -WorksheetName "Certificates" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter
    $Webdomains | Export-Excel $excel_path -WorksheetName "Webdomains" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter
    $Ips_Hosts | Export-Excel $excel_path -WorksheetName "Ips_Hosts" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter
    $Ips_Hosts_subnet | Export-Excel $excel_path -WorksheetName "Ips_Hosts_subnet" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter

    # Extension list comes as an array without name
    # dumping array from row 2 and manually setting colum name in row 1
    $Extensions | Export-Excel $excel_path -WorksheetName "Extensions" -ClearSheet -StartRow 2
    $Excel_imported = Open-ExcelPackage -Path $excel_path
    $Excel_imported.'Extensions'.cells["a1"].Value = 'Extensions'
    Close-ExcelPackage -ExcelPackage $Excel_imported

    $Files | ConvertTo-FlatObject | Export-Excel $excel_path -WorksheetName "Files" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter
    $Directories | ConvertTo-FlatObject | Export-Excel $excel_path -WorksheetName "Directories" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter
}
