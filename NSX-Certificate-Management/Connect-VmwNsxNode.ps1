Function Connect-VmwNsxNode {
    $script:connectUri = Read-Host -Prompt 'NSX Manager FQDN or IP'
    $script:connectCredential = Get-Credential -Title "Enterprise Admin User Information"
    $script:skipCertificateCheck = $true
    $script:AuthenticationMethod = "Basic"
}