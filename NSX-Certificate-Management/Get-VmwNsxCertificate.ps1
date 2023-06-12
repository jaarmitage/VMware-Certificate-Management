Function Get-VmwNsxCertificate {
    Param(
        [parameter(Position=0,Mandatory=$true)][Version]$Version,
        [parameter(Mandatory=$false)][string]$Node
    )

    $conn = nsxCheckCredential

    If ($conn -eq $true) {
        Get-ReqNsxTrustManagementCerticicates -apiVersion $Version -node $Node
    } Else {
        errHandler 1002
    }
}