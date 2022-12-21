function Merge-SepCloudAllowListAndExcelReport {
    <#
    .SYNOPSIS
        Merges a SEP Cloud Allow list policy and an exported policy as Excel in a single object without duplicates
    .DESCRIPTION
        Merges a SEP Cloud Allow list policy with with an exported allow list policy as an excel file (from Get-SepCloudPolicyDetails)
    .NOTES

    .INPUTS
        Policy object (from Get-SepCloudPolicyDetails)
        Excel report as an object
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Merge-SepCloudPolicyAndExcelReport
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>


    param (
        # policy object
        [Parameter(
        )]
        [Object]
        # TODO remove hardcoded policy object for dev
        $obj_allow_list = (Get-SepCloudPolicyDetails -name "AB - Testing - Allowlist"),

        # excel path
        [Parameter(
        )]
        [string]
        [Alias("Excel")]
        # TODO remove hardcoded excel path for dev
        $excel_path = ".\Data\Workstations_allowlist.xlsx"
    )


}
