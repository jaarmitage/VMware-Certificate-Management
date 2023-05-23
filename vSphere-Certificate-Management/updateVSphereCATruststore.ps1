<#

PowerCLI script to update the certificate authority store file (CA Store)
on a vSphere host using VMware-PowerCLI.

Author: Joshua Armitage (jarmitage@vmware.com)

Note: This requires PowerShell 5.1 or later and PowerCLI 12.3 or later.

#>

. ".\common.ps1"

Function addNewHostCsv {
    Param(
        [parameter(Mandatory=$true)][Int]$index,
        [parameter(Mandatory=$true)][String]$DNS1,
        [parameter(Mandatory=$false)][String]$errText
    )

    New-Object PsObject -property @{
        'Name' = 'ESXi Host ' + $index
        'Hostname' = $DNS1
        'Error' = $errText
    }
}

If ($global:DefaultVIServers.Count -ge 1) {
    Write-Host "Select connected vCenter Server to proceed"

    $viSelectMenu = @{}

    For ($i=1; $i -le ($global:DefaultVIServers.Count +1); $i++) {
        If ($i -le $global:DefaultVIServers.Count) {
            Write-Host "$i. $($global:DefaultVIServers[$i-1].Name)"
            $viSelectMenu.Add($i,($global:DefaultVIServers[$i-1].Name))
        } Else {
            #Write-Host "0. ALL"
            $viSelectMenu.Add(0,"ALL")
        }
    }

    [int]$ans = Read-Host 'Enter Selection'
    $viSel = $viSelectMenu.Item($ans)

    Write-Host $viSel
    Write-Host " "
    Write-Host "-----"
    Write-Host " "
    Write-Host "Select vSphere host cluster to proceed"
    Write-Host " "

    If ($viSel -eq "ALL") {
        $clusters = Get-Cluster | Select-Object -Property Name
    } Else {
        $clusters = Get-Cluster -Server $viSel | Select-Object -Property Name | Sort-Object -Property Name
    }

    $cluSelectMenu = @{}

    For ($i=1; $i -le ($clusters.count +1); $i++) {
        If ($i -le $clusters.count) {
            Write-Host "$i. $($clusters[$i-1].Name)"
            $cluSelectMenu.Add($i,($clusters[$i-1].Name))
        } Else {
            Write-Host "0. ALL"
            $cluSelectMenu.Add(0,"ALL")
        }
    }

    [int]$ans = Read-Host 'Enter Selection'
    $cluSel = $cluSelectMenu.Item($ans)

    If ($cluSel -eq "ALL") {
        $hosts = Get-VMHost | Where-Object { ($_.ConnectionState -eq "Connected") -or ($_.ConnectionState -eq "Maintenance") } | Select-Object -Property Name
    } Else {
        $hosts = Get-VMHost -Location $cluSel | Where-Object { ($_.ConnectionState -eq "Connected") -or ($_.ConnectionState -eq "Maintenance") } | Select-Object -Property Name | Sort-Object -Property Name
    }

    If ($hosts.count -ge 1) {
        $hostSelectMenu = @{}
        Write-Host "Select vSphere host to proceed"
        Write-Host " "
        For ($i=1; $i -le ($hosts.count +1); $i++) {
            If ($i -le $hosts.count) {
                Write-Host "$i. $($hosts[$i-1].Name)"
                $hostSelectMenu.Add($i,($hosts[$i-1].Name))
            } Else {
                Write-Host "0. ALL"
                $hostSelectMenu.Add(0,"ALL")
            }
        }
        [int]$ans = Read-Host 'Enter Selection'
        $hostSel = $hostSelectMenu.Item($ans)
    } Else {
        Write-Host "No connected hosts in cluster selection."
        Break
    }

    Write-Host " "
    Write-Host "-----"
    Write-Host " "

    If ($cluSel -ne "ALL") {
        Write-Host "Selected cluster: $cluSel"
        If ($hostSel -ne "ALL") {
            Write-Host "Selected host: $hostSel"
            $workingHosts = Get-VMHost -Location $cluSel -Name $hostSel
        } Else {
            Write-Host "Selected host: ALL"
            $workingHosts = Get-VMHost -Location $cluSel
        }
    } Else {
        Write-Host  "Selected cluster: ALL"
        $workingHosts = Get-VMHost
    }
} Else {
    Write-Host "Not connected to any vCenter Servers."
}

If ($workingHosts -ne $null) {

    # Common credential object is not needed as we are using authenticated vCenter session.
    # $commonCredential = setVshCredential
    # Write-Host $commonCredential

    $arrReport = ".\output_" + $env:username + "_" + (Get-Date).ToString('yyyymmddhhmm') + ".csv"
    $newCsvResultSet = @()
    $stepHostCsv = 0
    $writeNewHostCsv = 0

    $fileOpen = Get-FileOpenDialog "C:\"
    $caCertObject = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($fileOpen)

    If ($?) {
        ForEach ($vshAddr in $workingHosts) {
            Get-VITrustedCertificate -VMHost $vshAddr | Where-Object { $_.Certificate.Extenions.CertificateAuthority -ne "True" } | Remove-VITrustedCertificate
            Add-VITrustedCertificate -X509Certificate $caCertObject -VMHost $vshAddr -Server $viSel
            $stepHostCsv++
            $newCsvResultSet += addNewHostCsv -index $stepHostCsv -DNS1 $vshAddr.Name -errText $error[0]
            Continue
        }
        $writeNewHostCsv = 1
    } Else {
        Write-Host "Selected file does not appear to be a valid X509 certificate object."
    }
}

If ($writeNewHostCsv -eq 1) {
    $newCsvResultSet | Export-Csv $arrReport
}