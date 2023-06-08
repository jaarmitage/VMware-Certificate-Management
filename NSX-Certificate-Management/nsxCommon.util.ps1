Function Connect-VmwNsxEndpoint {
    $connectionUri = Read-Host -Prompt 'NSX Manager FQDN or IP'
    $connectionUser = Read-Host -Prompt 'NSX Administrative User'
    $connectionPass = Read-Host -AsSecureString -Prompt 'Password'
    Return New-Object System.Management.Automation.PSCredential ($connectionUser, $connectionPass)
}