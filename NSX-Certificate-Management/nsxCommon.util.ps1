Function CheckNsxCredential {
    If (-Not($script:connectCredential)) {
        Write-Host "No NSX endpoint saved."
        Return $false
        Connect-VmwNsxNode
    } Else {
        Write-Host "Connection info found."
        Return $true
    }
}