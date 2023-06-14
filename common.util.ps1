class VMWCertificate {
    [X509Certificate]$certificate
}

class VMWConnections {
    [string]$VMWHostName
}

Function CheckCertificateValidity {
    
}

Function CheckSupportedVersion {
    Param(
        [parameter(Position=0,Mandatory=$true)][Version]$Version,
        [parameter(Position=0,Mandatory=$true)][Version]$MaxVersion,
        [parameter(Position=0,Mandatory=$true)][Version]$MinVersion
    )

    If (($Version -gt [Version]$MaxVersion) -or ($Version -lt [Version]$MinVersion)) {
        Return $false
    } Elseif (($Version -ge [Version]$MinVersion) -and ($Version -le [Version]$MaxVersion)) {
        Return $true
    } Else {
        Throw "Unable to parse supplied version information."
    }
}
Function ConstructCSR {
    param()

    $content = '[ req ]
    default_bits = $constKeyBitLength
    default_keyfile = ' + $constFqdn + '.key
    distinguished_name = req_distinguished_name
    encrypt_key = no
    prompt = no
    string_mask = nombstr
    req_extensions = v3_req
    
    [ v3_req ]
    basicConstraints = CA:FALSE
    keyUsage = digitalSignature, keyEncipherment, dataEncipherment, nonRepudiation
    extendedKeyUsage = serverAuth, clientAuth
    
    [ req_distinguished_name ]
    countryName = US
    stateOrProvinceName = FL
    localityName = Pensacola
    0.organizationName = DHS
    organizationalUnitName = CISA
    commonName = ' + $requestID + '
    
    '
}

Function FileOpenDialog([string] $initialDirectory){

    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "Certificate Files (*.cer)| *.cer|Certificate Files (*.crt)| *.crt"
    $OpenFileDialog.ShowDialog() |  Out-Null

    return $OpenFileDialog.filename
}
Function selectMenu($arrMenuItems, $incAllItem) {
    $selectMenu = @{}

    For ($i=1; $i -le ($arrMenuItems.count +1); $i++) {
        If ($i -le $arrMenuItems.count) {
            Write-Host "$i. $($arrMenuItems[$i-1].name)"
            $selectMenu.Add($i,($arrMenuItems[$i-1].name))
        } ElseIf ($incAllItem) {
            Write-Host "0. ALL"
            $selectMenu.Add(0,"ALL")
        }
    }

    [int]$ans = Read-Host 'Enter Selection'
    Return $selectMenu.Item($ans)
}