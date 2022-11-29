# PSSymantecCloud

This PowerShell module provides a series of cmdlets for interacting with the [Symantec Endpoint Protection REST API](https://apidocs.securitycloud.symantec.com/#/doc?id=ses_auth)

## Overview
This small project is a *work in progress* attempt to interat with the Symantec/Broadcom API to manage Symantec Endpoint Protection (SEP) Cloud.
After importing this module, to interact with your SEP Cloud platform you need to 
- Create an [integration application](https://techdocs.broadcom.com/us/en/symantec-security-software/endpoint-security-and-management/endpoint-security/sescloud/Settings/creating-a-client-application-v132702110-d4152e4057.html) and get your ClientID & Secret
- Generate your [authentication token](https://apidocs.securitycloud.symantec.com/#/doc?id=ses_auth) (Go to SES > Generating your token bearer)


This module does:
- leverages the [Broadcom API documentation](https://apidocs.securitycloud.symantec.com/#/)
- follows the [Module Builder Project](https://github.com/PoshCode/ModuleBuilder) folder structure for easy maintenance and versioning
- run command `Test-SepCloudConnectivity`

## Usage
2 ways to install this module :
- the [Powershell Gallery](https://www.powershellgallery.com/packages/PSSymantecCloud/) with `Install-Module PSSymantecCloud`
- Build it from sources See [about this module](##Building-your-module)

### Authentication
Any command from this mordule will require a first client/secret input to generate in your [SEP Cloud console integration menu](https://sep.securitycloud.symantec.com/v2/integration/client-applications) that will be used for authentication and refreshing token

### Examples
Test if your authentication against the API is successful
```PowerShell
Test-SepCloudConnectivity
```

#### Devices
list of all your devices, currently connected considered "SECURE", "AT_RISK", or "COMPROMISED"
```PowerShell
Get-SepCloudDeviceList -Device_Status "AT_RISK" -Online
```
#### Incidents
list of all your incidents, including all events, for the past 7 (or 30) days.
```PowerShell
Get-SepCloudIncidents -Include_Events -Past_7_Days
```
**Note**: all data are stored for a maximum of 30 days


Get all opened incidents
```PowerShell
Get-SepCloudIncidents -Open
```

Get a custom list of incidents based on a specific query, using supported Lucene query language. eg.
Different incident states : 0 Unknown | 1 New | 2 In Progress | 3 On Hold | 4 Resolved | 5 Closed
```PowerShell
Get-SepCloudIncidents -Query "(state_id: 4 OR state_id: 5 ) AND conclusion:"Malicious Activity""
```

#### Policies
List of all policies
```PowerShell
PS C:\> Get-SepCloudPolices

total policies
----- --------
  111 {@{name=Block USB Device Control Policy; author=Aurelien Boumanne; policy_uid=59ab09bd...
```

Get policy details for a specific version
```PowerShell
Get-SepCloudPolicyDetails -Name "My Policy" -Version 5
```
**Note: By default, will output the latest version**

Export "allow list" policy to a customized Excel sheet
```PowerShell
Get-SepCloudPolicyDetails -Name "My Allow List Policy" | Export-SepCloudPolicyToExcel -Path "allow_list.xlsx"
```

## Building your module
To build the module, you need to have [ModuleBuilder](https://www.powershellgallery.com/packages/ModuleBuilder/)

1. Install ModuleBuilder `Install-Module -Name ModuleBuilder`

2. Get the source 
 ```powershell
 git clone https://github.com/Douda/PSSymantecCloud
cd PSSymantecCloud
```

3. run `Install-RequiredModule`

4. run `Build-Module .\Source -SemVer 1.0.0`
**Note: a build version will be required when building the module, eg. 1.0.0**

5. compiled module appears in the `Output` folder

## Versioning

ModuleBuilder will automatically apply the next semver version
if you have installed [gitversion](https://gitversion.readthedocs.io/en/latest/).

To manually create a new version run `Build-Module .\Source -SemVer 0.0.2`

## Additional Information

https://github.com/PoshCode/ModuleBuilder
