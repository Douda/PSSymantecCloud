# class addjson {
#     [object] $add
#     # Setting up the PSCustomObject structure from the JSON example : https://pastebin.com/FaKYpgw3
#     # TODO finish obj structure
#     addjson() {
#         $this.add = [pscustomobject]@{
#             applications = [System.Collections.Generic.List[object]]::new()
#             windows      = [PSCustomObject]@{
#                 files       = [System.Collections.Generic.List[object]]::new()
#                 directories = [System.Collections.Generic.List[object]]::new()
#             }
#         }
#     }
#     # method to add APPLICATIONS tab to the main obj
#     [void] AddProcessFile(
#         [string] $sha2,
#         [string] $name
#     ) {
#         $this.add.applications.Add([pscustomobject]@{
#                 processfile = [pscustomobject]@{
#                     sha2 = $sha2
#                     name = $name
#                 }
#             })
#     }
#     # Method to add FILES excel tab to obj
#     [void] AddWindowsFiles(
#         [string] $pathvariable,
#         [string] $path,
#         [bool] $scheduled,
#         [array] $features
#     ) {
#         $this.add.windows.files.add([pscustomobject]@{
#                 pathvariable = $pathvariable
#                 path         = $path
#                 scheduled    = $scheduled
#                 features     = $features
#             })
#     }
# }

class addjson {
    [object] $add
    # Setting up the PSCustomObject structure from the JSON example : https://pastebin.com/FaKYpgw3
    # TODO finish obj structure
    addjson() {
        $allowlist = [allowlist]::new()
        $this.add = $allowlist
    }
}

class allowlist {
    [object] $Applications
    [object] $Certificates
    [object] $webdomains
    [object] $ips_hosts
    [object] $windows
    # Setting up the PSCustomObject structure from the JSON example : https://pastebin.com/FaKYpgw3
    # TODO finish obj structure
    allowlist() {
        $this.applications = [System.Collections.Generic.List[object]]::new()
        $this.Certificates = [System.Collections.Generic.List[object]]::new()
        $this.webdomains = [System.Collections.Generic.List[object]]::new()
        $this.ips_hosts = [System.Collections.Generic.List[object]]::new()
        $this.windows = [PSCustomObject]@{
            files       = [System.Collections.Generic.List[object]]::new()
            directories = [System.Collections.Generic.List[object]]::new()
        }
    }

    # method to add APPLICATIONS tab to the main obj
    [void] AddProcessFile(
        [string] $sha2,
        [string] $name
    ) {
        $this.applications.Add([pscustomobject]@{
                processfile = [pscustomobject]@{
                    sha2 = $sha2
                    name = $name
                }
            })
    }

    # Method to add CERTIFICATES tab to the main obj
    [void] AddCertificates(
        [string] $signature_issuer,
        [string] $signature_company_name,
        [string] $signature_fingerprint,
        [string] $algorithm,
        [string] $value
    ) {
        $this.certificates.Add()
        $this.certificates.Add([pscustomobject]@{
                signature_issuer       = $signature_issuer
                signature_company_name = $signature_company_name
                signature_fingerprint  = [pscustomobject]@{
                    algorithm = $algorithm
                    value     = $value
                }
            })
    }

    # Method to add WEBDOMAINS to the main obj
    [void] AddWebDomains(
        [string] $domain
    ) {
        $this.webdomains.add([PSCustomObject]@{
                domain = $domain
            })
    }

    # Method to add IPS_HOSTS to the main obj
    [void] AddIpsHosts(
        [string] $ip
    ) {
        $this.ips_hosts.add([PSCustomObject]@{
                ip = $ip
            })
    }

    #Method to add EXTENSIONS tab to the main obj
    [void] AddExtensions(
        [array] $names,
        [bool] $scheduled,
        [array] $features
    ) {
        $this.extensions.add([PSCustomObject]@{
                names     = $names
                scheduled = $scheduled
                features  = $features
            })
    }

    # Method to add FILES excel tab to obj
    [void] AddWindowsFiles(
        [string] $pathvariable,
        [string] $path,
        [bool] $scheduled,
        [array] $features
    ) {
        $this.windows.files.add([pscustomobject]@{
                pathvariable = $pathvariable
                path         = $path
                scheduled    = $scheduled
                features     = $features
            })
    }

    # Method to add FILES excel tab to obj
    [void] AddWindowsDirectories(
        [string] $pathvariable,
        [string] $directory,
        [bool] $recursive,
        [bool] $scheduled,
        [array] $features
    ) {
        $this.windows.directories.add([pscustomobject]@{
                pathvariable = $pathvariable
                directory    = $directory
                recursive    = $recursive
                scheduled    = $scheduled
                features     = $features
            })
    }
}
