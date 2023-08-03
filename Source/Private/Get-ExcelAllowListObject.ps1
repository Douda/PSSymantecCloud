function Get-ExcelAllowListObject {
    <# TODO fill description
    .SYNOPSIS
        Imports excel allow list report from its file path as a PSObject
    .DESCRIPTION
        Imports excel allow list report as a PSObject.
        Same structure that Get-SepCloudPolicyDetails uses to compare Excel allow list and SEP Cloud allow list policy
    .EXAMPLE
        Get-ExcelAllowListObject -Path "WorkstationsAllowListPolicy.xlsx"
        Imports the excel file and returns a structured PSObject
    .INPUTS
        Excel path of allow list policy previously generated from Export-SepCloudAllowListPolicyToExcel CmdLet
    .OUTPUTS
        Custom PSObject
    #>

    param (
        # excel path
        [Parameter(
            ValueFromPipeline
        )]
        [string[]]
        [Alias("Excel")]
        [Alias("Path")]
        $excel_path
    )

    process {

        # List all excel tabs
        $AllSheets = Get-ExcelSheetInfo $excel_path
        $SheetsInfo = @{}
        # Import all Excel info in $SheetsInfo hashtable
        $AllSheets | ForEach-Object { $SheetsInfo[$_.Name] = Import-Excel $_.Path -WorksheetName $_.Name }

        # Get Object from ExceptionStructure Class
        $obj_policy_excel = [ExceptionStructure]::new()

        # Populates $obj_policy_excel

        # Add Applications
        foreach ($line in $SheetsInfo['Applications']) {
            $obj_policy_excel.AddProcessFile(
                $line.sha2,
                $line.Name
            )
        }

        # Add Files
        foreach ($line in $SheetsInfo['Files']) {
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
        foreach ($line in $SheetsInfo['Directories']) {
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

        # Add Extensions
        # no loop required, whole array needed
        $obj_policy_excel.AddExtensions(@{
                names     = $sheetsInfo['Extensions'].extensions
                scheduled = $true
                features  = 'AUTO_PROTECT'
            }
        )

        # Add WebDomains
        foreach ($line in $SheetsInfo['Webdomains']) {
            $obj_policy_excel.AddWebDomains(
                $line.domain
            )
        }

        # Add IPS Hosts
        foreach ($line in $SheetsInfo['Ips_Hosts']) {
            $obj_policy_excel.AddIpsHostsIpv4Address(
                $line.ip
            )
        }

        # Add IPS Subnet v4
        foreach ($line in $SheetsInfo['Ips_Hosts_subnet_v4']) {
            $obj_policy_excel.AddIpsHostsIpv4Subnet(
                $line.ip,
                $line.mask
            )
        }

        # Add IPS Subnet v6
        foreach ($line in $SheetsInfo['Ips_Hosts_subnet_v6']) {
            $obj_policy_excel.AddIpsHostsIpv6Subnet(
                $line.ipv6_subnet
            )
        }

        # Add IPs ranges (includes both IPv4 & v6)
        foreach ($line in $SheetsInfo['Ips_range']) {
            $obj_policy_excel.AddIpsRange(
                $line.ip_start,
                $line.ip_end
            )
        }

        # Add Certificates
        foreach ($line in $SheetsInfo['Certificates']) {
            $obj_policy_excel.AddCertificates(
                $line.signature_issuer,
                $line.signature_company_name,
                $line."signature_fingerprint.algorithm",
                $line."signature_fingerprint.value"
            )
        }

        # Add Linux Files
        foreach ($line in $SheetsInfo['Linux Files']) {
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
            # Use AddLinuxFiles
            $obj_policy_excel.AddLinuxFiles(
                $line.pathvariable,
                $line.path,
                $line.scheduled,
                $feature_names
            )
        }

        # Add Mac Files
        foreach ($line in $SheetsInfo['Mac Files']) {
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
            # Use AddMacFiles
            $obj_policy_excel.AddMacFiles(
                $line.pathvariable,
                $line.path,
                $line.scheduled,
                $feature_names
            )
        }



        # Add Linux Directories
        foreach ($line in $SheetsInfo['Linux Directories']) {
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
            # Use AddLinuxDirectories
            $obj_policy_excel.AddLinuxDirectories(
                $line.pathvariable,
                $line.directory,
                $line.recursive,
                $line.scheduled,
                $feature_names
            )
        }

        # Add Mac Directories
        foreach ($line in $SheetsInfo['Mac Directories']) {
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
            # Use AddMacDirectories
            $obj_policy_excel.AddMacDirectories(
                $line.pathvariable,
                $line.directory,
                $line.recursive,
                $line.scheduled,
                $feature_names
            )
        }

        return $obj_policy_excel
    }
}
