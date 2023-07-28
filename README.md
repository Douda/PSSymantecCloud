# PSSymantecCloud

This PowerShell module provides a series of cmdlets for interacting with the [Symantec Endpoint Protection REST API](https://apidocs.securitycloud.symantec.com/#/doc?id=ses_auth)

## Overview
This small project is a *work in progress* attempt to interact with the Symantec/Broadcom API to manage Symantec Endpoint Protection (SEP) Cloud.
To interact with your SEP Cloud platform you need to 
- Create an [integration application](https://techdocs.broadcom.com/us/en/symantec-security-software/endpoint-security-and-management/endpoint-security/sescloud/Settings/creating-a-client-application-v132702110-d4152e4057.html) and get your ClientID & Secret
- Generate your [authentication token](https://apidocs.securitycloud.symantec.com/#/doc?id=ses_auth) (Go to SES > Generating your token bearer)


This module does:
- leverage the [Broadcom API documentation](https://apidocs.securitycloud.symantec.com/#/)
- follow the [Module Builder Project](https://github.com/PoshCode/ModuleBuilder) folder structure for easy maintenance and versioning

## Usage
2 ways to install this module :
- Via [Powershell Gallery](https://www.powershellgallery.com/packages/PSSymantecCloud/) with `Install-Module PSSymantecCloud`
- Build it from sources See [about this module](##Building-your-module)

## List of commands
```PowerShell
Export-SepCloudPolicyToExcel
Get-SepCloudDeviceInfo
Get-SepCloudDeviceList
Get-SepCloudEvents
Get-SepCloudFeatureList
Get-SepCloudIncidents
Get-SepCloudPolices
Get-SepCloudPolicyDetails
Test-SepCloudConnectivity
```

### Authentication
Generate your authentication token via your [SEP Cloud console integration menu](https://sep.securitycloud.symantec.com/v2/integration/client-applications) and keep your ClientID & Secret

### Examples
Test if your authentication against the API is successful
```PowerShell
Test-SepCloudConnectivity

PS C:\Projects\PSSymantecCloud> Test-SepCloudConnectivity
True
```

#### Devices
list of all your devices
```PowerShell
Get-SepCloudDeviceList
```

list of all your devices that are considered "SECURE", "AT_RISK", or "COMPROMISED"
```PowerShell
Get-SepCloudDeviceList -Device_Status "AT_RISK"
```

Get details from a specific device
```PowerShell
Get-SepCloudDeviceList -Computername MyComputer

id                       : abcdefghijkl
name                     : MyComputer
host                     : MyComputer
domain                   : contoso.com
created                  : 10/10/2022 11:47:44
modified                 : 19/07/2023 21:57:27
os                       : @{ver=10.0.19045; name=Windows 10 Enterprise Edition; type=WINDOWS_WORKSTATION; 64_bit=True; lang=fr; major_ver=10; minor_ver=0; sp=0; tz_offset=60; user=first.last; user_domain=CONTOSO.COM; vol_avail_mb=93037; vol_cap_mb=241126}
hw                       : @{uuid=XXXXXXX-E406-5392-66BC-B3AEE4BC9185; bios_ver=ACER - 12F0 R1CET66W(1.35 ); cpu_mhz=2096; cpu_type=AMD64 Family 23 Model 96 Stepping 1; log_cpus=12; mem_mb=15592; model_vendor=ACER; serial=PC201T75}
adapters                 : {@{addr=74:4C:A1:B5:C9:0D; category=Public; ipv4Address=192.168.128.20; ipv4_gw=192.168.128.1; ipv4_prefix=24; mask=255.255.255.0}}
is_virtual               : False
dns_names                : {192.168.1.1…}
parent_device_group_id   : XXXX-KeUTx2ao0zIr0fpyA
parent_device_group_name : Workstations
device_status            : SECURE
connection_status        : ONLINE
```
Get detailed info from an asset using device_ID
```PowerShell
Get-SepCloudDeviceInfo -Device_ID abcdefghijkl
```
#### Incidents

list of all your opened incidents
```PowerShell
Get-SepCloudIncidents -Open
```

list of all your incidents, including all events
```PowerShell
Get-SepCloudIncidents -Include_Events
```
**Note**: Broadcom stores all data for a maximum of 30 days

Get a custom list of incidents based on a specific query, using supported [Lucene query language](https://techdocs.broadcom.com/us/en/symantec-security-software/endpoint-security-and-management/endpoint-detection-and-response/4-5/about-the-ways-to-search-for-indicators-of-comprom-v115770112-d38e14827/search-query-syntax-v124335086-d38e19040.html). 

Example : different incident states : 0 Unknown | 1 New | 2 In Progress | 3 On Hold | 4 Resolved | 5 Closed
```PowerShell
Get-SepCloudIncidents -Query "(state_id: 4 OR state_id: 5 ) AND conclusion:"Malicious Activity""
```

#### Policies
List of all policies
```PowerShell
PS C:\> Get-SepCloudPolices

total policies
----- --------
  111 {@{name=Block USB Device Control Policy; author=Aurelien Boumanne; policy_uid=xxxxxxx...
```

Get policy details for a specific version
```PowerShell
Get-SepCloudPolicyDetails -Name "My Policy" -Version 5
```
**Note**: By default, will output the latest version

##### Allow list policy
Allow list policy has a complex stucture. You can easily export it in an Excel format using the following syntax
```PowerShell
Get-SepCloudPolicyDetails -Name "My Allow List Policy" | Export-SepCloudPolicyToExcel -Path "allow_list.xlsx"
```

## Building your module
To build the module, you need to have [ModuleBuilder](https://www.powershellgallery.com/packages/ModuleBuilder/)

1. Install ModuleBuilder `Install-Module -Name ModuleBuilder`

2. Clone the PSSymantecCloud repository
 ```powershell
 git clone https://github.com/Douda/PSSymantecCloud
cd PSSymantecCloud
```

3. run `Install-RequiredModule`

4. run `Build-Module .\Source -SemVer 1.0.0`
   
**Note: a build version will be required when building the module, eg. 1.0.0**
compiled module appears in the `Output` folder

5. import the newmy built module `Import-Module .\Output\PSSymantecCloud\1.0.0\PSSymantecCloud.ps1m -Force`


## Versioning

ModuleBuilder will automatically apply the next semver version
if you have installed [gitversion](https://gitversion.readthedocs.io/en/latest/).

To manually create a new version run `Build-Module .\Source -SemVer 0.0.2`

## Additional Information

https://github.com/PoshCode/ModuleBuilder
