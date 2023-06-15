Function Get-VmwNsxCertificate {
    Param(
        [parameter(Mandatory=$false)][Version]$Version = $vmwNsxLatestVersion,
        [parameter(Mandatory=$false)][string]$Node
    )

    $conn = nsxCheckCredential

    If ($conn -eq $true) {
        Get-ReqNsxTrustManagementCerticicates -apiVersion $Version -node $Node
    } Else {
        errHandler 1002
    }
}