#TODO finish reporting script

<#
For monthly detection report : use following event type ID (sources - Symantec ICD Schema - https://icd-schema.symantec.com/types/1)
Boot Record Detection, 8025
User Session Detection, 8026
Process Detection, 8027
Get-Module Detection, 8028
Kernel Detection, 8030
File Detection, 8031
Registry Key Detection, 8032
Registry Value Detection, 8033

Below are the values or the "id" property to know the action taken for the detection
0	Unknown
1	Blocked
2	Allowed
3	No Action
4	Logged
5	Command Script Run
6	Corrected
7	Partially Corrected
8	Uncorrected
10	Delayed	Requires reboot to finish the operation.
11	Deleted
12	Quarantined
13	Restored
14	Detected
15	Exonerated	No longer suspicious (re-scored).
16	Tagged	Marked with extended attributes.

#>
Install-Module -Name PSSymantecCloud

# Query MALWARE PROTECTION feature (AutoProtect) & File-Detection type
# Temp query for testing "device_name:WRK201LPE091XHK AND type_id:8031 AND file.name:"BUDGET 2010 RP FC TL _04.12.09.xls""
# Original query : "feature_name:MALWARE_PROTECTION AND type_id:8031"
$resp = Get-SepCloudEvents -Query 'device_name:WRK201LPE091XHK AND type_id:8031'
$array = @()
foreach ($r in $resp) {
    <# $r is the current item #>
    $hashlist = [ordered]@{
        ComputerName      = $r.device_name
        OperatingSystem   = $r.device_os_name
        SepGroup          = $r.device_group
        SepVersion        = $r.product_ver
        DetectionFile     = $r.file.name
        DetectionFullPath = $r.file.path
        Time              = $r.time
        ThreatName        = $r.threat.name
        Action            = $r.id
    }

    $array += $hashlist
}
$array

