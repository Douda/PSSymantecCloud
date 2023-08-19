function Optimize-SepCloudAllowListPolicyObject {
    <#
    .SYNOPSIS
        Deletes empty properties from a Symantec Endpoint Cloud Allow List policy object
    .DESCRIPTION
        This function is used to remove empty properties from a Symantec Endpoint Cloud Allow List policy object.
        This is used before converting the object to JSON to avoid having empty properties in the JSON file used to update the policy
    .INPUTS
        - Symantec Endpoint Cloud Allow List policy object object
    .OUTPUTS
        - PSObject with empty properties removed
    .EXAMPLE


    #>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($obj in $InputObject) {
            # Listing all properties of the object
            $AllProperties = $obj.psobject.properties.Name
            foreach ($property in $AllProperties) {
                # # If the property is different from null (does not include empty strings)
                # if ($null -ne $obj.$property) {
                #     # parsing specific scenarios first
                #     # Specific use case. If the property is called "extensions",lookup if names is empty. If so, remove the whole extensions property
                #     if ( $obj.$property.PSObject.Properties.name -eq "Extensions") {
                #         if ($obj.$property.Extensions.names.Count -eq 0) {
                #             $obj.$property.PSObject.Properties.Remove("Extensions")
                #         }
                #     }

                # If the property is an object
                if ($obj.$property -is [object] -and $obj.$property -isnot [string]) {
                    # if nested object has empty property, remove it from the object
                    if ($obj.$property.Count -eq 0) {
                        $obj.PSObject.Properties.Remove($property)
                    } else {
                        # else, recursively call the function to dig deeper
                        Optimize-SepCloudAllowListPolicyObject $obj.$property
                        # if nested object has no property names (to avoid having empty objects that still return count to 1), remove the object
                        if ($null -eq $obj.$property.PSObject.Properties.name) {
                            $obj.psobject.Properties.Remove($property)
                        }
                    }
                }
            }
        }
        return $InputObject
    }
}
