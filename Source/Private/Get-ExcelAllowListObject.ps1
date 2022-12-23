function Get-ExcelAllowListObject {
    <# TODO fill description
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>

    param (
        # excel path
        [Parameter(
        )]
        [string]
        [Alias("Excel")]
        # TODO remove hardcoded excel path for dev
        $excel_path = ".\Data\Workstations_allowlist.xlsx"
    )
    # # List all excel tabs
    $AllSheets = Get-ExcelSheetInfo $excel_path
    $AllItemsInAllSheets = $AllSheets | ForEach-Object { Import-Excel $_.Path -WorksheetName $_.Name }
    # # Init
    $Applications = Import-Excel -Path "$excel_path" -WorksheetName Applications
    $Certificates = Import-Excel -Path "$excel_path" -WorksheetName Certificates
    $Webdomains = Import-Excel -Path "$excel_path" -WorksheetName Webdomains
    $Ips_Hosts = Import-Excel -Path "$excel_path" -WorksheetName Ips_Hosts
    $Extensions = Import-Excel -Path "$excel_path" -WorksheetName Extensions
    $Files = Import-Excel -Path "$excel_path" -WorksheetName Files
    $Directories = Import-Excel -Path "$excel_path" -WorksheetName Directories

    # Get Object from AllowList Class
    $obj_policy_excel = [allowlist]::new()

    # Add Applications
    foreach ($line in $Applications) {
        $obj_policy_excel.AddProcessFile(
            $line.sha2,
            $line.Name
        )
    }

    # Add Certificates
    foreach ($line in $Certificates) {
        $obj_policy_excel.AddCertificates(
            $line.signature_issuer,
            $line.signature_company_name,
            $line."signature_fingerprint.algorithm",
            $line."signature_fingerprint.value"
        )
    }

    # Add WebDomains
    foreach ($line in $Webdomains) {
        $obj_policy_excel.AddWebDomains(
            $line.domain
        )
    }

    # Add IPS Hosts
    foreach ($line in $Ips_Hosts) {
        $obj_policy_excel.AddIpsHosts(
            $line.ip
        )
    }
    # Add Extensions
    $obj_policy_excel.AddExtensions(@{
            names     = $Extensions.extensions
            scheduled = $true
            features  = 'AUTO_PROTECT'
        }
    )
    # # Add Files
    # foreach ($line in $Files) {
    #     [array]$features = @()
    #     [array]$FeatureNumbers = $line.PSObject.properties.name | Select-String -Pattern feature
    #     $obj_policy_excel.AddWindowsFiles(
    #         $line.Extensions
    #     )
    # }

    # $obj_policy_excel
}
