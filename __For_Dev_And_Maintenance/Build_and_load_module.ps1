# Setting up Paths & Variables
$ModuleDevPath = Split-Path -Path $PSScriptRoot -Parent
$BuildModuleSourcePath = $ModuleDevPath + "\Source\PSSymantecCloud.psd1"
# $MajorMinorPatch = dotnet-gitversion | ConvertFrom-Json | Select-Object -Expand MajorMinorPatch
$FullSemVer = dotnet-gitversion | ConvertFrom-Json | Select-Object -Expand FullSemVer
# $ImportModulePath = $ModuleDevPath + "\Output\PSSymantecCloud\" + $MajorMinorPatch + "\PSSymantecCloud.psm1"
$ImportModulePath = $ModuleDevPath + "\Output\PSSymantecCloud\PSSymantecCloud.psm1"

# Build Module
Build-Module -SourcePath $BuildModuleSourcePath -SemVer $FullSemVer
Import-Module -Name "$ImportModulePath" -Force
