function Merge-SepCloudAllowList {
    <# TODO add description
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
        - Excel report file path (generated from Export-SepCloudPolicyToExcel CmdLet)
    .OUTPUTS
        - Custom PSObject
    .EXAMPLE
        Get-SepCloudPolicyDetails -policy_name "My Policy" -policy_version "5" | Merge-SepCloudAllowList -Excel ".\Data\AllowlistReportForWorkstations.xlsx"
        Gathers SEP Cloud policy, compare it with an excel based allow list policy and returns differences
    .EXAMPLE
        Get-SepCloudPolicyDetails -policy_name "My Policy" | Merge-SepCloudAllowList -Excel ".\Data\Excel.xlsx" | Update-SepCloudAllowlistPolicy
        TODO : verify this example works
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
    $obj_policy = Get-SepCloudPolicyDetails -Policy_Name $Policy_Name -Policy_Version $Policy_Version

    # Import excel report as a structured object with
    $obj_policy_excel = Get-ExcelAllowListObject -Path $excel_path

    # Initialize structured obj that will be later converted
    # to HTTP JSON Body with "add" and "remove" hive
    $obj_body = [UpdateAllowlist]::new()

    # Comparison starts here
    <#
        As there are no built-in ways to compare 2 deeply nested PSObject
        Parse through every allow list type (Applications/certificates/etc...) and compare as followed :
        - If exception type (file/hash/etc) found in both excel / baseline policy : no changes
        - If found in Excel but not in baseline : set it in "add" hive
        - If found in baseline but not Excel : set it in "remove" hive

        UPDATE
        - instead of adding the logic in this function (Update-SepCloudAllowlistPolicy)
        - Create the Merge-SepCloudAllowList function to compare 2 "ExceptionStructure" classes
    #>

    # Comparison with "Applications" tab
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

    # Comparison with "Certificates" tab
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

    # Comparison with "Webdomains" tab
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

    # Comparison with "Ips_hosts" tab
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

    # Comparison with "Ips_Hosts_subnet" tab
    $policy_ips_hosts_subnet = $obj_policy.features.configuration.ips_hosts.ipv4_subnet
    $excel_ips_hosts_subnet = $obj_policy_excel.ips_hosts.ipv4_subnet
    foreach ($line in $excel_ips_hosts_subnet) {
        # Getting rid of null arrays in IPS subnets
        if ($null -ne $line) {
            # If same IP + mask appears in both lists
            if ($policy_ips_hosts_subnet.ip.contains($line.ip) -and $policy_ips_hosts_subnet.mask.contains($line.mask)) {
                # No changes needed
                continue
            } else {
                # if Ips_Hosts_subnet only in excel list
                # set the Ips_Hosts_subnet to the "add" hive
                $obj_body.add.AddIpsHostsIpv4Subnet(
                    $line.ip,
                    $line.mask
                )
            }
        }
    }

    # Parsing then policy object
    foreach ($line in $policy_ips_hosts_subnet) {
        # if Ips_Hosts_subnet appears only in policy (so not in Excel)
        if (-not $excel_ips_hosts_subnet.ip.contains($line.ip) -and $excel_ips_hosts_subnet.mask.contains($line.mask)) {
            # set the Ips_Hosts_subnet to the "remove" hive
            $obj_body.remove.AddIpsHostsIpv4Subnet(
                $line.ip,
                $line.mask
            )
        }
    }

    # Comparison with "Extensions" tab
    $policy_extensions = $obj_policy.features.configuration.extensions
    $excel_extensions = $obj_policy_excel.extensions
    foreach ($line in $excel_extensions.names) {
        # If extension appears in both lists
        if ($policy_extensions.names.contains($line.names)) {
            # No changes needed
            continue
        } else {
            # if extension only in excel list, set the extension to the "add" hive
            [PSCustomObject]$ext = @{
                Names     = $line
                scheduled = $true
                features  = 'AUTO_PROTECT'
            }
            $obj_body.add.AddExtensions(
                $ext
            )
        }
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
    )}

    # Comparison ends here
    # ...

    return $obj_body
}
