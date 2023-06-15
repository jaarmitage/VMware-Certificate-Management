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

    $vmwNsxConnectSpec.Uri = Read-Host -Prompt "NSX Endpoint Address"
    $vmwNsxConnectSpec.ApiVer = "3.2.1"
    $vmwNsxConnectSpec.Credential = Get-Credential -Message "Enterprise Admin User Role Required"
    $vmwNsxConnectSpec.SkipCertCheck = $true
    $vmwNsxConnectSpec.AuthMethod = "Basic"
}
