#TODO finish reporting script

<#
.SYNOPSIS
    Scripts gathers MALWARE_PROTECTION information from SEP Cloud console.
    Exports data in a formatted xlsx format
.DESCRIPTION
    Runs the following query against the SEP Cloud API 'feature_name:MALWARE_PROTECTION AND type_id:8031'
.INPUTS
    Policy object from get-sepcloudpolicyDetails
    Path required full filepath to export the report
.OUTPUTS
    xlsx formatted report
.NOTES
    Created by: Aurélien BOUMANNE (02122022)
.EXAMPLE
    .\Get-FileDetectionReport.ps1 -Path C:\Script\MyMonthlyFileDetectionReport.xlsx
#>

param (
    # Path of Export
    [Parameter(
        Mandatory
    )]
    [string]
    $Path
)

# Required modules
if (Get-Module -ListAvailable -Name PSSymantecCloud) {
    Write-Host "Module PSSymantecCloud exists, skpping install"
} else {
    Install-Module -Name PSSymantecCloud -Force
}

if (Get-Module -ListAvailable -Name ImportExcel) {
    Write-Host "Module ImportExcel exists, skpping install"
} else {
    Install-Module -Name ImportExcel -Force
}

# Query MALWARE PROTECTION feature (AutoProtect) & File-Detection type
# Query examples
# 'feature_name:MALWARE_PROTECTION AND type_id:8031'
# 'device_name:MachineName AND type_id:8031'
Write-Verbose "Querying SEP Cloud API"
$resp = Get-SepCloudEvents -Query 'feature_name:MALWARE_PROTECTION AND type_id:8031'
$array = @()
$i = 0
$total = $resp.Count

# Parse response
Write-Verbose "Processing SEP Cloud events"
foreach ($r in $resp) {
    $Obj = [pscustomobject]@{
        ComputerName      = $r.device_name
        Time              = $r.time
        DetectionFile     = $r.file.name
        ThreatName        = $r.threat.name
        Action            = $r.id
        SepVersion        = $r.product_ver
        OperatingSystem   = $r.device_os_name
        SepGroup          = $r.device_group
        DetectionFullPath = $r.file.path
    }
    $array += $Obj
    $i++
    $percentComplete = ($i / $total) * 100
    Write-Progress -Activity "Processing SEP Cloud events" -Status "Processing event $i of $total" -PercentComplete $percentComplete
}

# Convert ID action value to human readable string
# Sources : https://icd-schema.symantec.com/type/8031 / Look "disposition"
$ActionId = @{
    0  = 'Unknown'
    1  = 'Blocked'
    2  = 'Allowed'
    3  = 'No Action'
    4  = 'Logged'
    5  = 'Command Script Run'
    6  = 'Corrected'
    7  = 'Partially Corrected'
    8  = 'Uncorrected'
    10 = 'Delayed	Requires reboot to finish the operation.'
    11 = 'Deleted'
    12 = 'Quarantined'
    13 = 'Restored'
    14 = 'Detected'
    15 = 'Exonerated	No longer suspicious (re-scored).'
    16 = 'Tagged	Marked with extended attributes.'
}

# source : https://stackoverflow.com/questions/74645516/replace-psobj-property-value-based-on-a-list
# parse array
foreach ($Item in $array) {
    # parse possible values
    foreach ($key in $ActionId.Keys) {
        if ($key -eq $item.Action) {
            $Item.Action = $ActionId[$key]
        }
    }
}


# Exporting data to Excel
$excel_params = @{
    ClearSheet   = $true
    BoldTopRow   = $true
    AutoSize     = $true
    FreezeTopRow = $true
    AutoFilter   = $true
}

$array | Export-Excel $Path -WorksheetName "File Detection" @excel_params
