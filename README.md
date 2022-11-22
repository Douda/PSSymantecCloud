# PSSymantecCloud

## Overview
This small project is a *work in progress* attempt to interat with the Symantec/Broadcom API to manage Symantec Endpoint Protection (SEP) Cloud.
After importing this module, to interact with your SEP Cloud platform you need to 
- Create an [integration application](https://techdocs.broadcom.com/us/en/symantec-security-software/endpoint-security-and-management/endpoint-security/sescloud/Settings/creating-a-client-application-v132702110-d4152e4057.html) and get your ClientID & Secret
- Generate your [authentication token](https://apidocs.securitycloud.symantec.com/#/doc?id=ses_auth) (Go to SES > Generating your token bearer)


This module does:
- leverages the [Broadcom API documentation](https://apidocs.securitycloud.symantec.com/#/)
- follows the [Module Builder Project](https://github.com/PoshCode/ModuleBuilder) folder structure for easy maintenance and versioning
- run command `Test-SepCloudConnectivity`

## About this module
This module follows the [Module Builder Project](https://github.com/PoshCode/ModuleBuilder#the-module-builder-project) folder structure. 
This means you will have to build this module with the module builder in order to use it.


## Requirements

```posh
Install-Script -Name Install-RequiredModule
```

## Building your module
To build the module, you need to have [ModuleBuilder](https://www.powershellgallery.com/packages/ModuleBuilder/)

1. Install ModuleBuilder `Install-Module -Name ModuleBuilder`

2. Get the source 
 ```powershell
 git clone https://github.com/Douda/PSSymantecCloud
cd Modulebuilder
```

3. run `Install-RequiredModule`

4. run `Build-Module .\Source`

5. compiled module appears in the `Output` folder

## Versioning

ModuleBuilder will automatically apply the next semver version
if you have installed [gitversion](https://gitversion.readthedocs.io/en/latest/).

To manually create a new version run `Build-Module .\Source -SemVer 0.0.2`

## Additional Information

https://github.com/PoshCode/ModuleBuilder
