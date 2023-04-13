Function setVshCredential {
    $hostUser = Read-Host -Prompt 'Local ESXi User'
    $hostPass = Read-Host -AsSecureString -Prompt 'Password'
    $hostRcSpecPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($hostPass))
    Return New-Object System.Management.Automation.PSCredential ($hostUser, $hostPass)
}

Function vshGetState($vsh) {
    Switch (Get-VMHost -Name $vsh | Select-Object -expand ConnectionState) {
        "Disconnected" {0}
        "NotResponding" {1}
        "Maintenance" {2}
        "Connected" {3}
    }
}

Function vshEnMaint($vsh) {
    Switch ((vshGetState($vsh))) {
        0 {errHandler 104 -vsh $vsh; Break}
        1 {errHandler 104 -vsh $vsh; Break}
        2 {errHandler 105 -vsh $vsh; Break}
        3 {Set-VMHost -VMHost $vsh -Confirm:$false -Evacuate -State Maintenance -VsanDataMigrationMode NoDataMigration -ErrorAction Stop; Break}
    }
}

Function vshExMaint($vsh) {
    Switch ((vshGetState($vsh))) {
        0 {errHandler 104 -vsh $vsh; Break}
        1 {errHandler 104 -vsh $vsh; Break}
        2 {Set-VMHost -VMHost $vsh -Confirm:$false -State Connected; Break}
        3 {errHandler 111 -vsh $vsh; Break}
    }
}

Function vshRbRc($vsh, $vshu, $vshp, $cert, $ssh) {
    Restart-VMHost -VMHost $vsh -Confirm:$false -Evacuate -RunAsync -ErrorAction Stop
    #Invoke-SSHCommand -SSHSession $ssh -Command "/sbin/services.sh restart" -TimeOut 120
    Set-VMHost -VMHost $vsh -State Disconnected
    Start-Sleep -Seconds 60

    # Define vSphere reconnect specification (no native PowerCLI method to do this)
    $hostSslId = Get-PfxCertificate -FilePath $cert | Select-Object -ExpandProperty Thumbprint
    $hostThmb = $hostSslId -replace '(..(?!$))','$1:'
    $vshReconnectSpec = New-Object VMware.Vim.HostConnectSpec
    $vshReconnectSpec.force = $true
    $vshReconnectSpec.sslThumbprint = $hostThmb
    $vshReconnectSpec.userName = $vshu
    $vshReconnectSpec.password = $vshp
    $hostReady = 0
    $hostRbRcChkCtr = 0
    Do {
        errHandler 808
        Start-Sleep -Seconds 60
        $hostRbRcChkCtr++
        # Update hostname in specification and invoke reconnect task
		# This presumes the client workstation has network access to the host via
		# TCP/902, which may not be available depending on local network policy.
		#
        # $vshNetStatus = (Test-NetConnection -ComputerName $hostfqdn -Port 902).TcpTestSucceeded
        # If($vshNetStatus -eq "True"){
        If ((vshGetState $vsh) -ge 2) {
            vshExMaint -vsh $vsh
            errHandler 112 -vsh $vsh
            $hostReady = 1
        } Else {
            errHandler 807 -vsh $vsh -ctr $hostRbRcChkCtr

            Get-VMHost -Name $vsh -State Disconnected,NotResponding | Foreach-Object {
                $vshost = $_
                $vshReconnectSpec.hostName = $vshost.name
                $vshost.extensionData.ReconnectHost_Task($vshReconnectSpec,$null)
            }
        }
    } While ($hostReady -eq 0)
}