# https://stackoverflow.com/a/74901407/2552996
class Extensions {
    [Collections.Generic.List[string]] $names = [Collections.Generic.List[string]]::new()
    [bool] $scheduled
    [Collections.Generic.List[string]] $features = [Collections.Generic.List[string]]::new()
}

class UpdateAllowlist {
    [object] $add
    [object] $remove
    UpdateAllowlist() {
        $ExceptionStructureAdd = [ExceptionStructure]::new()
        $ExceptionStructureRemove = [ExceptionStructure]::new()
        $this.add = $ExceptionStructureAdd
        $this.remove = $ExceptionStructureRemove
    }

}

class ExceptionStructure {
    [object] $Applications
    [object] $Certificates
    [object] $webdomains
    [object] $ips_hosts
    [Extensions] $Extensions
    [object] $windows
    # Setting up the PSCustomObject structure from the JSON example : https://pastebin.com/FaKYpgw3
    # TODO finish obj structure
    ExceptionStructure() {
        $this.applications = [System.Collections.Generic.List[object]]::new()
        $this.Certificates = [System.Collections.Generic.List[object]]::new()
        $this.webdomains = [System.Collections.Generic.List[object]]::new()
        $this.ips_hosts = [System.Collections.Generic.List[object]]::new()
        $this.extensions = [Extensions]::new()
        # TODO Extensions obj be hashtable. Converting to JSON will not be incorrect format (list instead of k/v pair)
        $this.windows = [PSCustomObject]@{
            files       = [System.Collections.Generic.List[object]]::new()
            directories = [System.Collections.Generic.List[object]]::new()
        }
        $this.Linux = [PSCustomObject]@{
            files       = [System.Collections.Generic.List[object]]::new()
            directories = [System.Collections.Generic.List[object]]::new()
        }
        $this.mac = [PSCustomObject]@{
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
        # [string] $signature_fingerprint,
        [string] $algorithm,
        [string] $value
    ) {
        # $this.certificates.Add()
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

    # Method to add IPv4 addresses IPS_HOSTS to the main obj
    [void] AddIpsHostsIpv4Address(
        [string] $ip
    ) {
        $this.ips_hosts.add([PSCustomObject]@{
                ip = $ip
            })
    }

    # Method to add IPv4 subnet IPS_HOSTS to the main obj
    [void] AddIpsHostsIpv4Subnet(
        [string] $ip,
        [string] $mask
    ) {
        $this.ips_hosts.add([pscustomobject]@{
                ipv4_subnet = [pscustomobject]@{
                    ip   = $ip
                    mask = $mask
                }
            })
    }

    # Method to add EXTENSIONS tab to the main obj
    [void] AddExtensions([Extensions] $Extension) {
        $this.Extensions = $Extension
    }

    # Method to add Windows FILES excel tab to obj
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

    # Method to add Linux FILES excel tab to obj
    [void] AddLinuxFiles(
        [string] $pathvariable,
        [string] $path,
        [bool] $scheduled,
        [array] $features
    ) {
        $this.linux.files.add([pscustomobject]@{
                pathvariable = $pathvariable
                path         = $path
                scheduled    = $scheduled
                features     = $features
            })
    }

    # Method to add Mac FILES excel tab to obj
    [void] AddMacFiles(
        [string] $pathvariable,
        [string] $path,
        [bool] $scheduled,
        [array] $features
    ) {
        $this.mac.files.add([pscustomobject]@{
                pathvariable = $pathvariable
                path         = $path
                scheduled    = $scheduled
                features     = $features
            })
    }

    # Method to add Windows DIRECTORIES excel tab to obj
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

    # Method to add Linux DIRECTORIES excel tab to obj
    [void] AddLinuxDirectories(
        [string] $pathvariable,
        [string] $directory,
        [bool] $recursive,
        [bool] $scheduled,
        [array] $features
    ) {
        $this.linux.directories.add([pscustomobject]@{
                pathvariable = $pathvariable
                directory    = $directory
                recursive    = $recursive
                scheduled    = $scheduled
                features     = $features
            })
    }

    # Method to add Mac DIRECTORIES excel tab to obj
    [void] AddMacDirectories(
        [string] $pathvariable,
        [string] $directory,
        [bool] $recursive,
        [bool] $scheduled,
        [array] $features
    ) {
        $this.mac.directories.add([pscustomobject]@{
                pathvariable = $pathvariable
                directory    = $directory
                recursive    = $recursive
                scheduled    = $scheduled
                features     = $features
            })
    }
}
