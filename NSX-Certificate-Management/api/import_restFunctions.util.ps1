Function Get-ReqNsxTrustManagementCerticicates {
    Param(
        [parameter(Position=0,Mandatory=$true)][Version]$apiVersion,
        [parameter(Mandatory=$false)][string]$node
    )

    $params = @{
        2.2 = @{
            Uri = 'https://' + $node + '/api/v1/system/certificates';
        };
        2.4 = @{
            Uri = 'https://' + $node + '/api/v1/trust-management/certificates';
        }
    }

    If (($apiVersion -gt [Version]$vmwNsxLatestVersion)) {
        Throw "Stated version is higher than maximum supported version."
    } Elseif (($apiVersion -ge [Version]"2.4") -and ($apiVersion -le [Version]$vmwNsxLatestVersion)) {
        $apiVersion = "2.4"
    } Elseif (($apiVersion -ge [Version]$vmwNsxLowestVersion) -and ($apiVersion -lt [Version]"2.4")) {
        $apiVersion = "2.2"
    } Else {
        Throw "Stated version is below lowest supported version."
    }

    $request = @{
        Uri = $params[$apiVersion]["Uri"]
        Authentication = $vmwNsxConnectSpec.AuthMethod
        Credential = $vmwNsxConnectSpec.Credential
        Method = "Get"
    }

    Return $request
}

Function Get-ReqNsxTrustManagementClusterCerticicates {
    Param(
        [parameter(Position=0,Mandatory=$true)][Version]$apiVersion,
        [parameter(Mandatory=$false)][string]$node
    )

    $request = @{
        2.2 = @{
            Uri = 'https://' + $node + '/api/v1/system/certificates';
            Headers = '2.2 Testing Headers';
            Body = '2.2 Request body test'
        };
        2.4 = @{
            Uri = 'https://' + $node + '/api/v1/trust-management/certificates';
            Headers = 'Testing 2.4 Headers';
            Body = '2.4 request body test'
        }
    }

    If (($apiVersion -gt [Version]$vmwNsxLatestVersion)) {
        Throw "Stated version is higher than maximum supported version."
    } Elseif (($apiVersion -ge [Version]"2.4") -and ($apiVersion -le [Version]$vmwNsxLatestVersion)) {
        $apiVersion = "2.4"
    } Elseif (($apiVersion -ge [Version]$vmwNsxLowestVersion) -and ($apiVersion -lt [Version]"2.4")) {
        $apiVersion = "2.2"
    } Else {
        Throw "Stated version is below lowest supported version."
    }

    $requestUri = Switch ($apiVersion) {
        2.4 {$request[2.4]["Uri"]; Break}
        2.2 {$request[2.2]["Uri"]; Break}
    }

    Return $requestUri
}