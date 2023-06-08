Function Set-VmwNsxClusterCertificate {
    $conn = CheckNsxCredential

    If ($conn -eq $true) {
        Write-Host "Yay!"
        #Invoke-RestMethod -Url "https://$($connectUri)/api/v1/cluster/api-certificate"
    } Else {
        Write-Host "Boo!"
    }
}