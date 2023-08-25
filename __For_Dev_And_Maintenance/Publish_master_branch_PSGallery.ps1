# Build and load module
# Loading Paths & Variables
. "$PSScriptRoot\Build_and_load_module.ps1"

# Import API Key
$API_PATH = Split-Path $ModuleDevPath -Parent
$API_KEY = Import-Clixml -Path "$API_PATH\API_KEY_PS_Gallery.xml" -ErrorAction SilentlyContinue
if ($null -eq $API_KEY) {
    $API_KEY = Read-Host -Prompt 'Enter PS Gallery API Key to publish the module'
}

# Publish Module
$MajorMinorPatch = dotnet-gitversion | ConvertFrom-Json | Select-Object -Expand MajorMinorPatch
Publish-Module -Path "C:\Users\aurel\OneDrive\Documents\Projects\PSSymantecCloud\Output\PSSymantecCloud\$MajorMinorPatch\" -NuGetApiKey $APIKey -Verbose
