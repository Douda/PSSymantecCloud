function Export-SepCloudDenyListPolicyToExcel {
    <# TODO : change help for deny list
    .SYNOPSIS
        Export a Deny List policy to a human readable excel report
    .INPUTS
        Policy name
        Policy version
        Excel path
    .OUTPUTS
        Excel file
    .DESCRIPTION
        Exports a Deny list policy object it to an Excel file, with one tab per allow type (Executable file / Non-PE file etc...)
        Supports pipeline input with allowlist policy object
    .EXAMPLE
        Export-SepCloudDenyListPolicyToExcel -Name "My Deny list Policy" -Version 1 -Path "deny_list.xlsx"
        Exports the policy with name "My Deny list Policy" and version 1 to an excel file named "deny_list.xlsx"
    .EXAMPLE
        Get-SepCloudPolicyDetails -Name "My Deny list Policy" | Export-SepCloudDenyListPolicyToExcel -Path "deny_list.xlsx"
        Gathers policy in an object, pipes the output to Export-SepCloudDenyListPolicyToExcel to export in excel format
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
            # ParameterSetName = 'PolicyName'
        )]
        [string]
        [Alias("Version")]
        $Policy_Version,

        # Exact policy name
        [Parameter(
            # ParameterSetName = 'PolicyName'
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

        # formating data
        # Explicitely define the properties to export for file actors
        $params_actor = @{
            Property = 'sha2', 'md5', 'directory'
        }
        # Explicitely define the properties to export for non-pe files
        $params_file = @{
            Property = 'name', 'sha2', 'size', 'directory'
        }
        # loop through all files and actors to select the properties we want to export
        $i = 0
        foreach ($n in $NonPEFiles) {
            $actors = $NonPEFiles[$i].actor | Select-Object @params_actor
            $NonPEFiles[$i].actor = $actors

            $files = $NonPEFiles[$i].file | Select-Object @params_file
            $NonPEFiles[$i].file = $files
            $i++
        }

        # Exporting data to Excel
        $excel_params = @{
            ClearSheet   = $true
            BoldTopRow   = $true
            AutoSize     = $true
            FreezeTopRow = $true
            AutoFilter   = $true
        }
        Import-Module -Name ImportExcel
        $Executable_Files | ConvertTo-FlatObject | Export-Excel $excel_path -WorksheetName "Executable Files" @excel_params
        $NonPEFiles | ConvertTo-FlatObject | Export-Excel $excel_path -WorksheetName "Non-PE Files" @excel_params
    }
}
