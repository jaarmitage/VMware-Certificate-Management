Function Set-VmwNsxClusterCertificate {
    $conn = CheckNsxCredential

    If ($conn -eq $true) {
        Write-Host "Yay!"
        errHandler 1001
        FileOpenDialog("D:\Google Drive\Common\Scripts")
        Write-Host $vmwNsxConnectSpec.Uri
        #Invoke-RestMethod -Url "https://$($connectUri)/api/v1/cluster/api-certificate"
    } Else {
        errHandler 1002
    }
}