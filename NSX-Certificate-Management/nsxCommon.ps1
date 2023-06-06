. ".\MainFunctions.ps1"

Function Set-NsxEndpoint {
    $connectionUri = Read-Host -Prompt 'NSX Manager FQDN or IP'
    $connectionUser = Read-Host -Prompt 'Local ESXi User'
    $connectionPass = Read-Host -AsSecureString -Prompt 'Password'
    Return New-Object System.Management.Automation.PSCredential ($hostUser, $hostPass)
}