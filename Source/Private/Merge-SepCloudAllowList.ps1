function Merge-SepCloudAllowList {
    <#
    .SYNOPSIS
        Merges 2 SEP Cloud allow list policy to a single PSObject
    .DESCRIPTION
        Returns a custom PSObject ready to be converted in json as HTTP Body for Update-SepCloudAllowlistPolicy CmdLet
        Excel file takes precedence in case of conflicts. It is the main "source of truth".
        Logic goes as below
        - If SEP exception present in both excel & policy : no changes
        - If SEP exception present only in Excel : add exception
        - If SEP exception present only in policy (so not in Excel) : remove exception
    .NOTES
        Excel file takes precedence in case of conflicts
    .INPUTS
        - SEP cloud allow list policy PSObject
        - Excel report file path (previously generated from Export-SepCloudAllowListPolicyToExcel CmdLet)
    .OUTPUTS
        - Custom PSObject
    .EXAMPLE
        Merge-SepCloudAllowList -Policy_Name "My Allow List Policy For Servers" -Excel ".\Data\Centralized_exceptions_for_servers.xlsx" | Update-SepCloudAllowlistPolicy
    #>

    param (
        # Policy version
        [Parameter(
        )]
        [string]
        [Alias("Version")]
        $Policy_Version,

        # Exact policy name
        [Parameter(
            Mandatory
        )]
        [string]
        [Alias("PolicyName")]
        $Policy_Name,

        # excel path
        [Parameter(
            Mandatory
        )]
        [string]
        [Alias("Excel")]
        [Alias("Path")]
        $excel_path
    )

    # Get policy details to compare with Excel file
    # Use specific version or by default latest version
    switch ($PSBoundParameters.Keys) {
        'Policy_Version' {
            $obj_policy = Get-SepCloudPolicyDetails -Policy_Name $Policy_Name -Policy_Version $Policy_Version
        }
        Default {}
    }

    if ($null -eq $PSBoundParameters['Policy_Version']) {
        $obj_policy = Get-SepCloudPolicyDetails -Policy_Name $Policy_Name
    }

    # Import excel report as a structured object with
    $obj_policy_excel = Get-ExcelAllowListObject -Path $excel_path

    # Initialize structured obj that will be later converted
    # to HTTP JSON Body with "add" and "remove" hive
    $obj_body = [UpdateAllowlist]::new()

    ###########################
    # Comparison starts here  #
    ###########################

    # "Applications" tab
    # Parsing excel object first
    $policy_sha2 = $obj_policy.features.configuration.applications.processfile
    $excel_sha2 = $obj_policy_excel.Applications.processfile
    # Parsing first excel object
    foreach ($line in $excel_sha2) {
        # if sha2 appears in both lists
        if ($policy_sha2.sha2.contains($line.sha2)) {
            # No changes needed
            continue
        } else {
            # if sha2 only in excel list, set the sha to the "add" hive
            $obj_body.add.AddProcessFile(
                $line.sha2,
                $line.name
            )
        }
    }
    # Parsing then policy object
    foreach ($line in $policy_sha2) {
        # if sha2 appears only in policy (so not in Excel)
        if (-not $excel_sha2.sha2.contains($line.sha2)) {
            # set the sha to the "remove" hive
            $obj_body.remove.AddProcessFile(
                $line.sha2,
                $line.name
            )
        }
    }

    # "Files" tab
    # Parsing excel object first
    $policy_files = $obj_policy.features.configuration.windows.files
    $excel_files = $obj_policy_excel.windows.files
    foreach ($line in $excel_files) {
        # If file appears in both lists
        if ($policy_files.path.contains($line.Path)) {
            # No changes needed
            continue
        } else {
            # if file only in excel list, set the file to the "add" hive
            $obj_body.add.AddWindowsFiles(
                $line.pathvariable,
                $line.path,
                $line.scheduled,
                $line.features
            )
        }
    }
    # Parsing then policy object
    foreach ($line in $policy_files) {
        # if file appears only in policy (so not in Excel)
        if (-not $excel_files.path.contains($line.path)) {
            # set the file to the "remove" hive
            $obj_body.remove.AddWindowsFiles(
                $line.pathvariable,
                $line.path,
                $line.scheduled,
                $line.features
            )
        }
    }

    # "Directories" tab
    # Parsing excel object first
    $policy_directories = $obj_policy.features.configuration.windows.directories
    $excel_directories = $obj_policy_excel.windows.directories
    foreach ($line in $excel_directories) {
        # If directory appears in both lists
        if ($policy_directories.directory.contains($line.directory)) {
            # No changes needed
            continue
        } else {
            # if directory only in excel list, set the directory to the "add" hive
            $obj_body.add.AddWindowsDirectories(
                $line.pathvariable,
                $line.directory,
                $line.recursive,
                $line.scheduled,
                $line.features
            )
        }
    }
    # parsing then policy object
    foreach ($line in $policy_directories) {
        # if directory appears only in policy (so not in Excel)
        if (-not $excel_directories.directory.contains($line.directory)) {
            # set the directory to the "remove" hive
            $obj_body.remove.AddWindowsDirectories(
                $line.pathvariable,
                $line.directory,
                $line.recursive,
                $line.scheduled,
                $line.features
            )
        }
    }

    # "Certificates" tab
    # Parsing excel object first
    # TODO confirm this is the right way to compare certificates
    $policy_certs = $obj_policy.features.configuration.certificates
    $excel_certs = $obj_policy_excel.certificates
    foreach ($line in $excel_certs) {
        # If certs appears in both lists
        if ($policy_certs.signature_fingerprint.value.contains($line.signature_fingerprint.value)) {
            # No changes needed
            continue
        } else {
            # if cert only in excel list, set the cert to the "add" hive
            $obj_body.add.AddCertificates(
                $line.signature_issuer,
                $line.signature_company_name,
                $line.signature_fingerprint.algorithm,
                $line.signature_fingerprint.value
            )
        }
    }

    # Parsing then policy object
    foreach ($line in $policy_certs) {
        # if cert appears only in policy (so not in Excel)
        if (-not $excel_certs.signature_fingerprint.value.contains($line.signature_fingerprint.value)) {
            # set the cert to the "remove" hive
            $obj_body.remove.AddCertificates(
                $line.signature_issuer,
                $line.signature_company_name,
                $line.signature_fingerprint.algorithm,
                $line.signature_fingerprint.value
            )
        }
    }

    # "Webdomains" tab
    # Parsing excel object first
    $policy_webdomains = $obj_policy.features.configuration.webdomains
    $excel_webdomains = $obj_policy_excel.webdomains
    foreach ($line in $excel_webdomains) {
        # If webdomain appears in both lists
        if ($policy_webdomains.domain.contains($line.domain)) {
            # No changes needed
            continue
        } else {
            # if webdomain only in excel list, set the webdomain to the "add" hive
            $obj_body.add.AddWebDomains(
                $line.domain
            )
        }
    }

    # Parsing then policy object
    foreach ($line in $policy_webdomains) {
        # if webdomain appears only in policy (so not in Excel)
        if (-not $excel_webdomains.domain.contains($line.domain)) {
            # set the webdomain to the "remove" hive
            $obj_body.remove.AddWebDomains(
                $line.domain
            )
        }
    }

    # "Ips_hosts" tab
    # Parsing excel object first
    $policy_ips_hosts = $obj_policy.features.configuration.ips_hosts
    $excel_ips_hosts = $obj_policy_excel.ips_hosts
    foreach ($line in $excel_ips_hosts) {
        # If Ips_hosts appears in both lists
        if ($policy_ips_hosts.ip.contains($line.ip)) {
            # No changes needed
            continue
        } else {
            # if Ips_hosts only in excel list, set the Ips_hosts to the "add" hive
            $obj_body.add.AddIpsHostsIpv4Address(
                $line.ip
            )
        }
    }

    # Parsing then policy object
    foreach ($line in $policy_ips_hosts) {
        # if Ips_hosts appears only in policy (so not in Excel)
        if (-not $excel_ips_hosts.ip.contains($line.ip)) {
            # set the Ips_hosts to the "remove" hive
            $obj_body.remove.AddIpsHostsIpv4Address(
                $line.ip
            )
        }
    }

    # "Ips_Hosts_subnet_v6" tab
    # Parsing excel object first
    $policy_ips_hosts_subnet_v6 = $obj_policy.features.configuration.ips_hosts.ipv6_subnet | Where-Object { $_ }
    $excel_ips_hosts_subnet_v6 = $obj_policy_excel.ips_hosts.ipv6_subnet | Where-Object { $_ }
    foreach ($line in $excel_ips_hosts_subnet_v6) {
        # if subnet appears in both lists
        if ($policy_ips_hosts_subnet_v6.contains($line)) {
            # no changes
            continue
        } else {
            # if subnet only in excel list, set the subnet to the "add" hive
            $obj_body.add.AddIpsHostsIpv6Subnet(
                $line
            )
        }
        # }
    }

    # parsing then policy object
    foreach ($line in $policy_ips_hosts_subnet_v6) {
        # if subnet appears only in policy (so not in Excel)
        if (-not $excel_ips_hosts_subnet_v6.contains($line)) {
            # set the subnet to the "remove" hive
            $obj_body.remove.AddIpsHostsIpv6Subnet(
                $line
            )
        }
    }

    # "ip ranges" tab
    # Parsing excel object first
    $policy_ip_range = $obj_policy.features.configuration.ips_hosts.ip_range | Where-Object { $_ }
    $excel_ip_range = $obj_policy_excel.ips_hosts.ip_range | Where-Object { $_ }
    foreach ($line in $excel_ip_range) {
        # If ip_start appears in both lists
        if ($policy_ip_range.ip_start.contains($line.ip_start)) {
            # find the index of the ip_start in the policy list
            $policy_index = $policy_ip_range.ip_start.IndexOf($line.ip_start)
            # use index to find the corresponding ip_end
            $policy_ip_end = $policy_ip_range.ip_end[$policy_index]
            # if policy_ip_end is the same as in excel list, no changes needed
            if ($policy_ip_end -eq $line.ip_end) {
                continue
            } else {
                # if policy_ip_end is different, remove the ip_start & ip_end from policy and ...
                $obj_body.remove.AddIpsRange(
                    $policy_ip_range.ip_start[$policy_index],
                    $policy_ip_range.ip_end[$policy_index]
                )
                # ... set the ip range from excel to the "add" hive
                $obj_body.add.AddIpsRange(
                    $line.ip_start,
                    $line.ip_end
                )
            }
        }
        # if ip_start appears only in excel list
        else {
            # set the ip range to the "add" hive
            $obj_body.add.AddIpsRange(
                $line.ip_start,
                $line.ip_end
            )
        }
    }

    # then parsing policy object
    foreach ($line in $policy_ip_range) {
        # if ip_start appears only in policy (so not in Excel)
        if (-not $excel_ip_range.ip_start.contains($line.ip_start)) {
            # set the ip range to the "remove" hive
            $obj_body.remove.AddIpsRange(
                $line.ip_start,
                $line.ip_end
            )
        }
    }

    # "Ips_Hosts_subnet_v4" tab
    # Parsing excel object first
    $policy_ips_hosts_subnet_v4 = $obj_policy.features.configuration.ips_hosts.ipv4_subnet | Where-Object { $_ }
    $excel_ips_hosts_subnet_v4 = $obj_policy_excel.ips_hosts.ipv4_subnet | Where-Object { $_ }
    foreach ($line in $excel_ips_hosts_subnet_v4) {
        # If ip appears in both lists
        if ($policy_ips_hosts_subnet_v4.ip.contains($line.ip)) {
            # find the index of the ip in the policy list
            $policy_index = $policy_ips_hosts_subnet_v4.ip.IndexOf($line.ip)
            # use index to find the corresponding mask
            $policy_mask = $policy_ips_hosts_subnet_v4.mask[$policy_index]
            # if policy_mask is the same as in excel list, no changes needed
            if ($policy_mask -eq $line.mask) {
                continue
            } else {
                # if policy_mask is different, remove the ip and mask from policy and ...
                $obj_body.remove.AddIpsHostsIpv4Subnet(
                    $policy_ips_hosts_subnet_v4.ip[$policy_index],
                    $policy_ips_hosts_subnet_v4.mask[$policy_index]
                )
                # ... set the ip from excel to the "add" hive
                $obj_body.add.AddIpsHostsIpv4Subnet(
                    $line.ip,
                    $line.mask
                )
            }
        }
    }

    # then parsing policy object
    foreach ($line in $policy_ips_hosts_subnet_v4) {
        # if ip appears only in policy (so not in Excel)
        if (-not $excel_ips_hosts_subnet_v4.ip.contains($line.ip)) {
            # set the ip to the "remove" hive
            $obj_body.remove.AddIpsHostsIpv4Subnet(
                $line.ip,
                $line.mask
            )
        }
    }

    # "Extensions" tab
    # Parsing excel object first
    $policy_extensions = $obj_policy.features.configuration.extensions
    $excel_extensions = $obj_policy_excel.extensions
    $extensions_list_to_add = @()
    foreach ($line in $excel_extensions.names) {
        # If extension appears in both lists
        if ($policy_extensions.names.contains($line)) {
            # No changes needed
            continue
        } else {
            # if extension only in excel list, set the extension to the "add" hive
            # Adding it to $extensions_list_to_add
            $extensions_list_to_add += $line
        }
    }
    # If extensions to add not empty
    if ($null -ne $extensions_list_to_add) {
        [PSCustomObject]$ext = @{
            Names     = $extensions_list_to_add
            scheduled = $true
            features  = 'AUTO_PROTECT'
        }
        $obj_body.add.AddExtensions(
            $ext
        )
    }

    # Parsing then policy object
    $extensions_list_to_remove = @()
    foreach ($line in $policy_extensions.names) {
        # if extension appears only in policy (so not in Excel)
        # Adding it to the $extensions_list_to_remove
        if (-not $excel_extensions.names.contains($line)) {
            $extensions_list_to_remove += $line
        }
    }
    # If extensions to remove not empty
    if ($null -ne $extensions_list_to_remove) {
        # set the extension to the "remove" hive
        [PSCustomObject]$ext = @{
            Names     = $extensions_list_to_remove
            scheduled = $true
            features  = 'AUTO_PROTECT'
        }
        $obj_body.remove.AddExtensions(
            $ext
        )
    }

    # "Linux Files" tab
    # Parsing excel object first
    $policy_linux_files = $obj_policy.features.configuration.linux.files
    $excel_linux_files = $obj_policy_excel.linux.files
    foreach ($line in $excel_linux_files) {
        # If file appears in both lists
        if ($policy_linux_files.contains($line.Path)) {
            # No changes needed
            continue
        } else {
            # if file only in excel list, set the file to the "add" hive
            $obj_body.add.AddLinuxFiles(
                $line.pathvariable,
                $line.path,
                $line.scheduled,
                $line.features
            )
        }
    }

    # Parsing then policy object
    foreach ($line in $policy_linux_files) {
        # if file appears only in policy (so not in Excel)
        if (-not $excel_linux_files.path.contains($line.path)) {
            # set the file to the "remove" hive
            $obj_body.remove.AddLinuxFiles(
                $line.pathvariable,
                $line.path,
                $line.scheduled,
                $line.features
            )
        }
    }

    # "Linux Directories" tab
    # Parsing excel object first
    $policy_linux_directories = $obj_policy.features.configuration.linux.directories
    $excel_linux_directories = $obj_policy_excel.linux.directories
    foreach ($line in $excel_linux_directories) {
        # If directory appears in both lists
        if ($policy_linux_directories.contains($line.directory)) {
            # No changes needed
            continue
        } else {
            # if directory only in excel list, set the directory to the "add" hive
            $obj_body.add.AddLinuxDirectories(
                $line.pathvariable,
                $line.directory,
                $line.recursive,
                $line.scheduled,
                $line.features
            )
        }
    }

    # Parsing then policy object
    foreach ($line in $policy_linux_directories) {
        # if directory appears only in policy (so not in Excel)
        if (-not $excel_linux_directories.directory.contains($line.directory)) {
            # set the directory to the "remove" hive
            $obj_body.remove.AddLinuxDirectories(
                $line.pathvariable,
                $line.directory,
                $line.recursive,
                $line.scheduled,
                $line.features
            )
        }
    }

    # "Mac Files" tab
    # Parsing excel object first
    $policy_mac_files = $obj_policy.features.configuration.mac.files
    $excel_mac_files = $obj_policy_excel.mac.files
    foreach ($line in $excel_mac_files) {
        # If file appears in both lists
        if ($policy_mac_files.contains($line.Path)) {
            # No changes needed
            continue
        } else {
            # if file only in excel list, set the file to the "add" hive
            $obj_body.add.AddMacFiles(
                $line.pathvariable,
                $line.path,
                $line.scheduled,
                $line.features
            )
        }
    }

    # Parsing then policy object
    foreach ($line in $policy_mac_files) {
        # if file appears only in policy (so not in Excel)
        if (-not $excel_mac_files.path.contains($line.path)) {
            # set the file to the "remove" hive
            $obj_body.remove.AddMacFiles(
                $line.pathvariable,
                $line.path,
                $line.scheduled,
                $line.features
            )
        }
    }

    # "Mac Directories" tab
    # Parsing excel object first
    $policy_mac_directories = $obj_policy.features.configuration.mac.directories
    $excel_mac_directories = $obj_policy_excel.mac.directories
    foreach ($line in $excel_mac_directories) {
        # If directory appears in both lists
        if ($policy_mac_directories.contains($line.directory)) {
            # No changes needed
            continue
        } else {
            # if directory only in excel list, set the directory to the "add" hive
            $obj_body.add.AddMacDirectories(
                $line.pathvariable,
                $line.directory,
                $line.recursive,
                $line.scheduled,
                $line.features
            )
        }
    }

    # Parsing then policy object
    foreach ($line in $policy_mac_directories) {
        # if directory appears only in policy (so not in Excel)
        if (-not $excel_mac_directories.directory.contains($line.directory)) {
            # set the directory to the "remove" hive
            $obj_body.remove.AddMacDirectories(
                $line.pathvariable,
                $line.directory,
                $line.recursive,
                $line.scheduled,
                $line.features
            )
        }
    }


    return $obj_body
}
