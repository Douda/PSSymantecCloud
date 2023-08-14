function Export-SepCloudDenyListPolicyToExcel {
    <# TODO : change help for deny list
    .SYNOPSIS
        Export an Allow List policy to a human readable excel report
    .INPUTS
        Policy name
        Policy version
        Excel path
    .OUTPUTS
        Excel file
    .DESCRIPTION
        Exports an allow list policy object it to an Excel file, with one tab per allow type (filename/file hash/directory etc...)
        Supports pipeline input with allowlist policy object
    .EXAMPLE
        Export-SepCloudAllowListPolicyToExcel -Name "My Allow list Policy" -Version 1 -Path "allow_list.xlsx"
        Exports the policy with name "My Allow list Policy" and version 1 to an excel file named "allow_list.xlsx"
    .EXAMPLE
        Get-SepCloudPolicyDetails -Name "My Allow list Policy" | Export-SepCloudAllowListPolicyToExcel -Path "allow_list.xlsx"
        Gathers policy in an object, pipes the output to Export-SepCloudAllowListPolicyToExcel to export in excel format
    #>
    [CmdletBinding(DefaultParameterSetName = 'PolicyName')]
    param (
        # Path of Export
        [Parameter(Mandatory)]
        [Alias('Excel', 'Path')]
        [string]
        $excel_path,

        # Policy version
        [Parameter(
            ParameterSetName = 'PolicyName'
        )]
        [string]
        [Alias("Version")]
        $Policy_Version,

        # Exact policy name
        [Parameter(
            ParameterSetName = 'PolicyName'
        )]
        [string]
        [Alias("Name")]
        $Policy_Name,

        # Policy Obj to work with
        [Parameter(
            ValueFromPipeline,
            ParameterSetName = 'PolicyObj'
        )]
        [Alias("PolicyObj")]
        [pscustomobject]
        $obj_policy
    )

    process {
        # If no PSObject is provided, get it from Get-SepCloudPolicyDetails
        if ($null -eq $PSBoundParameters['obj_policy']) {
            # Use specific version or by default latest
            if ($Policy_version -ne "") {
                $obj_policy = Get-SepCloudPolicyDetails -Name $Policy_Name -Policy_Version $Policy_Version
            } else {
                $obj_policy = Get-SepCloudPolicyDetails -Name $Policy_Name
            }
        }

        # Verify the policy is a deny list policy
        if ($obj_policy.type -ne "BLACKLIST") {
            throw "ERROR - The policy is not a deny list policy"
        }

        # init
        $Executable_Files = $obj_policy.features.configuration.blacklistrules
        $NonPEFiles = $obj_policy.features.configuration.nonperules

        # Exporting data to Excel
        Import-Module -Name ImportExcel
        $Executable_Files | ConvertTo-FlatObject | Export-Excel $excel_path -WorksheetName "Executable Files" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter
        $NonPEFiles | ConvertTo-FlatObject | Export-Excel $excel_path -WorksheetName "Non-PE Files" -ClearSheet -BoldTopRow -AutoSize -FreezeTopRow -AutoFilter
    }
}
