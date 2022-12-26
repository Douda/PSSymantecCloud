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
    # Add Files
    foreach ($line in $Files) {
        # Parse "features.X" properties to gather the feature names in an array
        [array]$feature_names = @()
        [array]$nb_features = $line.PSObject.properties.name | Select-String -Pattern feature
        $i = 0
        foreach ($feat in $nb_features) {
            if ($null -ne $line.($nb_features[$i])) {
                $feature_names += $line.($nb_features[$i])
            }
            $i++
        }
        # Use AddWindwsFiles
        $obj_policy_excel.AddWindowsFiles(
            $line.pathvariable,
            $line.path,
            $line.scheduled,
            $feature_names
        )
    }

    # Add Directories
    foreach ($line in $Directories) {
        # Parse "features.X" properties to gather the feature names in an array
        [array]$feature_names = @()
        [array]$nb_features = $line.PSObject.properties.name | Select-String -Pattern feature
        $i = 0
        foreach ($feat in $nb_features) {
            if ($null -ne $line.($nb_features[$i])) {
                $feature_names += $line.($nb_features[$i])
            }
            $i++
        }
        # Use AddWindwsFiles
        $obj_policy_excel.AddWindowsDirectories(
            $line.pathvariable,
            $line.directory,
            $line.recursive,
            $line.scheduled,
            $feature_names
        )
    }


    # TODO remove output $obj_policy_excel
    $obj_policy_excel
}
