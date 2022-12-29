function Merge-SepCloudAllowList {
    <# TODO add description
    .SYNOPSIS
        Merges 2 SEP Cloud allow list policy to a single PSObject
    .DESCRIPTION
        Returns a custom PSObject ready to be converted in json for Update-SepCloudAllowlistPolicy CmdLet
        Excel file takes precedence in case of conflicts. It is the main "source of truth". logic goes as below
        - If exception present in both excel & policy : no changes
        - If exception present only in Excel : add exception
        - If exception present only in policy (so not in Excel) : remove exception
    .NOTES
        Excel file takes precedence in case of conflicts
    .INPUTS
        - Sep cloud allow list policy PSObject
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
            ParameterSetName = 'Policy'
        )]
        [string]
        [Alias("Version")]
        $Policy_Version,

        # Exact policy name
        [Parameter(
            ValueFromPipeline
            # Mandatory
            # TODO add mandatory
        )]
        [string]
        [Alias("PolicyName")]
        # TODO remove hardcoded info
        $Policy_Name = "AB - Testing - Allowlist",

        # excel path
        [Parameter(
            Mandatory
        )]
        [string]
        [Alias("Excel")]
        [Alias("Path")]
        # TODO remove hardcoded excel path for dev
        $excel_path # = ".\Data\Workstations_allowlist.xlsx"
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
            # TODO can remove sha2 from policy obj to reduce 2nd pass load
            continue
        } else {
            # if sha2 only in excel list
            # set the sha to the "add" hive
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
            # TODO can remove certs from policy obj to reduce 2nd pass load
            continue
        } else {
            # if cert only in excel list
            # set the cert to the "add" hive
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
            # set the sha to the "remove" hive
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
            # TODO can remove certs from policy obj to reduce 2nd pass load
            continue
        } else {
            # if webdomain only in excel list
            # set the cert to the "add" hive
            $obj_body.add.AddWebDomains(
                $line.domain
            )
        }
    }

    # Parsing then policy object
    foreach ($line in $policy_webdomains) {
        # if webdomain appears only in policy (so not in Excel)
        if (-not $excel_webdomains.domain.contains($line.domain)) {
            # set the sha to the "remove" hive
            $obj_body.remove.AddWebDomains(
                $line.domain
            )
        }
    }

    # Comparison with "Ips_hosts" tab
    $policy_ips_hosts = $obj_policy.features.configuration.ips_hosts
    $excel_ips_hosts = $obj_policy_excel.ips_hosts
    foreach ($line in $excel_ips_hosts) {
        # If webdomain appears in both lists
        if ($policy_ips_hosts.ip.contains($line.ip)) {
            # No changes needed
            # TODO can remove certs from policy obj to reduce 2nd pass load
            continue
        } else {
            # if webdomain only in excel list
            # set the cert to the "add" hive
            $obj_body.add.AddIpsHosts(
                $line.ip
            )
        }
    }

    # Parsing then policy object
    foreach ($line in $policy_ips_hosts) {
        # if webdomain appears only in policy (so not in Excel)
        if (-not $excel_ips_hosts.ip.contains($line.ip)) {
            # set the sha to the "remove" hive
            $obj_body.remove.AddIpsHosts(
                $line.ip
            )
        }
    }

    # TODO IPS host only currently works for IPv4 addresses, not with subnets
    # Could be related to Get-SepCloudPolicyDetails function
    # After initial investigation, looks like the PSObject shows "empty" for every subnet, we can access it
    # with ...

    # Comparison ends here
    # ...

    return $obj_body
}
