# Build and load module
# Loading Paths & Variables
. "$PSScriptRoot\Build_and_load_module.ps1"

# # Build Help
# $OutputFolder = $ModuleDevPath + "\Help"
# $parameters = @{
#     Module                = "PSSymantecCloud"
#     OutputFolder          = $OutputFolder
#     AlphabeticParamsOrder = $true
#     WithModulePage        = $true
#     ExcludeDontShow       = $true
#     Encoding              = [System.Text.Encoding]::UTF8
# }
# New-MarkdownHelp @parameters

# New-MarkdownAboutHelp -OutputFolder $OutputFolder -AboutName "topic_name"

# Update Help
$parameters = @{
    Path                  = $ModuleDevPath + "\Help"
    RefreshModulePage     = $true
    AlphabeticParamsOrder = $true
    UpdateInputOutput     = $true
    ExcludeDontShow       = $true
    # LogPath               = $ModuleDevPath + "\Help\Log.log"
    Encoding              = [System.Text.Encoding]::UTF8
}
Update-MarkdownHelpModule @parameters
