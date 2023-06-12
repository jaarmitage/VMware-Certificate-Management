# Function establishing connection parameters for VMWare NSX-T Datacenter Manager Node.

$vmwNsxConnectSpec = [ordered]@{
    Uri = $null
    ApiVer = $null
    Credential = $null
    SkipCertCheck = $null
    AuthMethod = $null
}

New-Variable -Name vmwNsxConnectSpec -Value $vmwNsxConnectSpec -Scope Script -Force

Function Connect-VmwNsxNode {
    [CmdletBinding()]
    param()

    $vmwNsxConnectSpec.Uri = "nms-nxm-01.core.lab"
    $vmwNsxConnectSpec.ApiVer = "3.2.1"
    $vmwNsxConnectSpec.Credential = Get-Credential -Title "Enterprise Admin User Role Required"
    $vmwNsxConnectSpec.SkipCertCheck = $true
    $vmwNsxConnectSpec.AuthMethod = "Basic"
}
<#
Function Connect-VmwNsxNode {
    $script:connectUri = Read-Host -Prompt 'NSX Manager FQDN or IP'
    $script:connectCredential = Get-Credential -Title "Enterprise Admin User Information"
    $script:skipCertificateCheck = $true
    $script:AuthenticationMethod = "Basic"
}
#>