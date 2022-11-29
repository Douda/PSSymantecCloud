function Export-SepCloudPolicyToExcel {
    <# TODO fill description
    .SYNOPSIS
        Export an Allow List policy object to excel
    .DESCRIPTION
        Takes an allow list policy object as input and exports it to an Excel file, with one tab per allow type (filename/file hash/directory etc...)
    .EXAMPLE
        Get-SepCloudPolicyDetails -Name "My Policy" | Export-SepCloudPolicyToExcel -Path "allow_list.xlsx"
        Gathers policy in an object, pipes the output to Export-SepCloudPolicyToExcel
    #>

    param (
        # Path of Export
        [Parameter()]
        [string]
        $Path,

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
    $allow_list | ConvertTo-Json -Depth 100 | Out-File -FilePath ".\Allow List Policy_v69.json"
    Get-SepCloudPolicyDetails -Policy_UUID "5e867f84-5e23-421c-adfd-XXXXXXXXXXXX" -Policy_version 9 | Convert-SepCloudPolicyToExcel -Path "C:\Test\test5.xlsx"
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
    $Applications = $obj_policy.features.configuration.applications.processfile
    $Certificates = $obj_policy.features.configuration.certificates
    $Webdomains = $obj_policy.features.configuration.webdomains
    $Ips_Hosts = $obj_policy.features.configuration.ips_hosts
    $Extensions = $obj_policy.features.configuration.extensions.names
    $Files = $obj_policy.features.configuration.windows.files
    $Directories = $obj_policy.features.configuration.windows.directories

    Import-Module -Name ImportExcel
    $Applications | Export-Excel $Path -WorksheetName "Applications" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter
    $Certificates | Export-Excel $Path -WorksheetName "Certificates" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter
    $Webdomains | Export-Excel $Path -WorksheetName "Webdomains" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter
    $Ips_Hosts | Export-Excel $Path -WorksheetName "Ips_Hosts" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter
    $Extensions | Export-Excel $Path -WorksheetName "Extensions" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter
    $Files | Export-Excel $Path -WorksheetName "Files" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter
    $Directories | Export-Excel $Path -WorksheetName "Directories" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter
}
