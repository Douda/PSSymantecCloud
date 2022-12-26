function Get-ExcelAllowListObject {
    <# TODO fill description
    .SYNOPSIS
        Imports excel allow list report as a PSObject
    .DESCRIPTION
        Imports excel allow list report as a PSObject. Same structure that Get-SepCloudPolicyDetails uses to compare Excel allow list and SEP Cloud allow list policy
    .EXAMPLE
        Get-ExcelAllowListObject -Excel "WorkstationsAllowListPolicy.xlsx"
        Imports the excel file and returns a strcutured PSObject
    .INPUTS
        Excel path of allow list policy previously generated from Export-SepCloudPolicyToExcel CmdLet
    .OUTPUTS
        Custom PSObject
    #>

    param (
        # excel path
        [Parameter(
        )]
        [string]
        [Alias("Excel")]
        [Alias("Path")]
        # TODO remove hardcoded excel path for dev
        $excel_path # = ".\Data\Workstations_allowlist.xlsx"
    )
    # # List all excel tabs
    # $AllSheets = Get-ExcelSheetInfo $excel_path
    # $AllItemsInAllSheets = $AllSheets | ForEach-Object { Import-Excel $_.Path -WorksheetName $_.Name }

    # Init
    $Applications = Import-Excel -Path "$excel_path" -WorksheetName Applications
    $Certificates = Import-Excel -Path "$excel_path" -WorksheetName Certificates
    $Webdomains = Import-Excel -Path "$excel_path" -WorksheetName Webdomains
    $Ips_Hosts = Import-Excel -Path "$excel_path" -WorksheetName Ips_Hosts
    $Extensions = Import-Excel -Path "$excel_path" -WorksheetName Extensions
    $Files = Import-Excel -Path "$excel_path" -WorksheetName Files
    $Directories = Import-Excel -Path "$excel_path" -WorksheetName Directories

    # Get Object from ExceptionStructure Class
    $obj_policy_excel = [ExceptionStructure]::new()

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
        # Parse "features.X" properties to gather the feature_names in an array
        [array]$feature_names = @()
        [array]$nb_features = $line.PSObject.properties.name | Select-String -Pattern feature
        $i = 0
        foreach ($feat in $nb_features) {
            if ($null -ne $line.($nb_features[$i])) {
                $feature_names += $line.($nb_features[$i])
            }
            $i++
        }
        # Use AddWindowsFiles
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
        # Use AddWindowsDirectories
        $obj_policy_excel.AddWindowsDirectories(
            $line.pathvariable,
            $line.directory,
            $line.recursive,
            $line.scheduled,
            $feature_names
        )
    }


    # TODO remove output $obj_policy_excel
    return $obj_policy_excel
}
