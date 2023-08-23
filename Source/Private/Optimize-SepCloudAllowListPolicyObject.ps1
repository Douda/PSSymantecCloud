function Optimize-SepCloudAllowListPolicyObject {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSObject]
        $obj
    )

    process {
        # Listing all properties of the object
        $AllProperties = $obj | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
        foreach ($property in $AllProperties) {
            switch ($property) {
                "add" {
                    # recursively call the function to dig deeper
                    $obj.add = Optimize-SepCloudAllowListPolicyObject $obj.$property
                    # Verify if the add object has no properties
                    if (($obj.add | Get-Member -MemberType NoteProperty).count -eq 0) {
                        # Remove the "add"  property from the object
                        $obj = $obj | Select-Object -ExcludeProperty $property
                    }
                }
                "remove" {
                    # recursively call the function to dig deeper
                    $obj.remove = Optimize-SepCloudAllowListPolicyObject $obj.$property
                    # Verify if the remove object has no properties
                    if (($obj.remove | Get-Member -MemberType NoteProperty).count -eq 0) {
                        # Remove the "remove" property from the object
                        $obj = $obj | Select-Object -ExcludeProperty $property
                    }
                }
                "applications" {
                    if ($obj.$property.processfile.count -eq 0) {
                        # Remove Applications property
                        $obj = $obj | Select-Object -ExcludeProperty $property
                    }
                }
                "webdomains" {
                    if ($obj.$property.count -eq 0) {
                        # Remove webdomains property
                        $obj = $obj | Select-Object -ExcludeProperty $property
                    }
                }
                "certificates" {
                    if ($obj.$property.count -eq 0) {
                        # Remove certificates property
                        $obj = $obj | Select-Object -ExcludeProperty $property
                    }
                }
                "ips_hosts" {
                    if ($obj.$property.count -eq 0) {
                        # Remove ips_hosts property
                        $obj = $obj | Select-Object -ExcludeProperty $property
                    }
                }
                "extensions" {
                    if ($obj.$property.names.count -eq 0) {
                        # Remove extensions property
                        $obj = $obj | Select-Object -ExcludeProperty $property
                    }
                }
                "linux" {
                    # Checking linux files
                    if ($obj.$property.files.count -eq 0) {
                        # Remove linux files property only
                        $obj.$property = $obj.$property | Select-Object -ExcludeProperty "files"
                    }
                    # Checking linux folders
                    if ($obj.$property.directories.count -eq 0) {
                        # Remove linux folders property only
                        $obj.$property = $obj.$property | Select-Object -ExcludeProperty "directories"
                    }
                    # If both files and folders are empty, remove the property
                    if ($obj.$property.files.count -eq 0 -and $obj.$property.directories.count -eq 0) {
                        $obj = $obj | Select-Object -ExcludeProperty $property
                    }
                }
                "windows" {
                    # Checking windows files
                    if ($obj.$property.files.count -eq 0) {
                        # Remove windows files property only
                        $obj.$property = $obj.$property | Select-Object -ExcludeProperty "files"
                    }
                    # Checking windows folders
                    if ($obj.$property.directories.count -eq 0) {
                        # Remove windows folders property only
                        $obj.$property = $obj.$property | Select-Object -ExcludeProperty "directories"
                    }
                    # If both files and folders are empty, remove the property
                    if ($obj.$property.files.count -eq 0 -and $obj.$property.directories.count -eq 0) {
                        $obj = $obj | Select-Object -ExcludeProperty $property
                    }
                }
                "mac" {
                    # Checking mac files
                    if ($obj.$property.files.count -eq 0) {
                        # Remove mac files property only
                        $obj.$property = $obj.$property | Select-Object -ExcludeProperty "files"
                    }
                    # Checking mac folders
                    if ($obj.$property.directories.count -eq 0) {
                        # Remove mac folders property only
                        $obj.$property = $obj.$property | Select-Object -ExcludeProperty "directories"
                    }
                    # If both files and folders are empty, remove the property
                    if ($obj.$property.files.count -eq 0 -and $obj.$property.directories.count -eq 0) {
                        $obj = $obj | Select-Object -ExcludeProperty $property
                    }
                }
                Default {}
            }
        }
        return $obj
    }
}
