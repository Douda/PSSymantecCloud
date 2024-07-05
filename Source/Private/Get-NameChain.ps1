function Get-NameChain {
    <#
    .SYNOPSIS
        Recursively builds a chain of group names from a group to the root.
    .DESCRIPTION
        Recursively builds a chain of group names from a group to the root.
    .EXAMPLE
        Get-NameChain -CurrentGroup $Group -AllGroups $Groups
    #>


    param (
        [PSCustomObject]$CurrentGroup,
        [Array]$AllGroups,
        [String]$Chain = ""
    )
    # If the current group is root (no parent_id), prepend its name to the chain.
    if (-not $CurrentGroup.parent_id) {
        if ($Chain -eq "") {
            return $CurrentGroup.name # If chain is empty, it's the root group.
        } else {
            return $CurrentGroup.name + "\" + $Chain # Prepend root name to chain.
        }
    } else {
        # Find the parent group.
        $ParentGroup = $AllGroups | Where-Object { $_.id -eq $CurrentGroup.parent_id }
        if ($ParentGroup) {
            # If there's a parent, prepend the parent's name to the chain and recurse.
            $NewChain = if ($Chain -eq "") { $CurrentGroup.name } else { $CurrentGroup.name + "\" + $Chain }
            return Get-NameChain -CurrentGroup $ParentGroup -AllGroups $AllGroups -Chain $NewChain
        } else {
            # If no parent found (which shouldn't happen), return the current chain.
            return $Chain
        }
    }
}
