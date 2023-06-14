New-Variable -Name vmwNsxLatestVersion -Value "4.1.0" -Scope Script -Force
New-Variable -Name vmwNsxLowestVersion -Value "2.2" -Scope Script -Force
New-Variable -Name vmwNsxSupportedVersions -Scope Script -Force

<#
$vmwNsxSupportedVersions = @(
    [Version]2.2,
    [Version]2.3,
    [Version]2.4,
    [Version]2.5,
    [Version]3.0,
    [Version]3.0.1,
    [Version]3.0.2,
    [Version]3.1.0,
    [Version]3.0.1,
    [Version]3.0.2,
    [Version]3.1.1,
    [Version]3.1.2,
    [Version]3.1.3,
    [Version]3.2.0,
    [Version]3.2.1,
    [Version]4.0.0,
    [Version]4.0.1,
    [Version]4.1.0
)
#>

class NSXConnectSpec : VMWConnections {
    [String]$b64credential
    [Version]$version
}

Function nsxFormatVersion {
    Param(
        [parameter(Position=0,Mandatory=$true)][Version]$version
    )

    Write-Host "Coming soon."
}
Function nsxCheckCredential {
    If (-Not($vmwNsxConnectSpec.Credential)) {
        Write-Host "No NSX endpoint saved."
        Return $false
    } Else {
        errHandler 1001
        Return $true
    }
}