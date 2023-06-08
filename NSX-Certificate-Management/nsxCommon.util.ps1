Function CheckNsxCredential {
    If (-Not($vmwNsxConnectSpec.Credential)) {
        Write-Host "No NSX endpoint saved."
        Return $false
        Connect-VmwNsxNode
    } Else {
        Write-Host errHandler 1001
        Return $true
    }
}