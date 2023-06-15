# Functions defining how to interact with select methods of the VMWare NSX-T Datacenter API.

Function Get-ReqNsxTrustManagementCerticicates {
    Param(
        [parameter(Mandatory=$false)][Version]$apiVersion = $vmwNsxLatestVersion,
        [parameter(Mandatory=$false)][string]$node = $vmwNsxConnectSpec.Uri
    )

    If (($apiVersion -gt [Version]$vmwNsxLatestVersion)) {
        Throw "Stated version is higher than maximum supported version."
    } Elseif (($apiVersion -ge [Version]"2.4") -and ($apiVersion -le [Version]$vmwNsxLatestVersion)) {
        $apiVersion = "2.4"
    } Elseif (($apiVersion -ge [Version]$vmwNsxLowestVersion) -and ($apiVersion -lt [Version]"2.4")) {
        $apiVersion = "2.2"
    } Else {
        Throw "Stated version is below lowest supported version."
    }

    $RSParams = @{
        [Version]2.2 = @{
            Uri = 'https://' + $node + '/trust-management/certificates'
        };
        [Version]2.4 = @{
            Uri = 'https://' + $node + '/api/v1/trust-management/certificates'
        }
    }

    $request = @{
        Uri = $RSParams[$apiVersion]["Uri"];
        Authentication = $vmwNsxConnectSpec.AuthMethod;
        Credential = $vmwNsxConnectSpec.Credential;
        Method = "Get"
    }

    Return $request
}

Function Get-ReqNsxTrustManagementClusterCerticicates {
    Param(
        [parameter(Mandatory=$false)][Version]$apiVersion = $vmwNsxLatestVersion,
        [parameter(Mandatory=$false)][string]$node = $vmwNsxConnectSpec.Uri
    )

    $request = @{
        [Version]2.2 = @{
            Uri = 'https://' + $node + '/api/v1/system/certificates'
        };
        [Version]2.4 = @{
            Uri = 'https://' + $node + '/api/v1/trust-management/certificates'
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
        Uri = $RSParams[$apiVersion]["Uri"];
        Authentication = $vmwNsxConnectSpec.AuthMethod;
        Credential = $vmwNsxConnectSpec.Credential;
        Method = "Get"
    }

    Return $request
}