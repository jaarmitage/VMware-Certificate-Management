. "..\errorHandler.ps1"
. ".\vshPkiCmdTest.ps1"
. ".\testFileOpen.ps1"

Function testCertKeyPair() {
	Param(
		[parameter(Mandatory=$true)][String]$testCert,
		[parameter(Mandatory=$true)][String]$testKey
	)
	
	If ($testCert -eq $testKey) {
		Return $true
	} Else {
		Return $false
	}
}

Function createConfig {
	Param (
		[parameter(Mandatory=$true)][int]$requestID,
		[parameter(Mandatory=$true)][String]$reqWD,
		[parameter(Mandatory=$true)][String]$reqHostFQDN
	)
		
	$content = '[ req ]
default_bits = 2048
default_keyfile = ' + $reqHostFQDN + '.key
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
	[String]$cfg = $reqWD + "/config.cfg"
	If (Test-Path -Path $cfg) {
		Write-Host "Found existing configuration for $reqHostFQDN, deleting."
		Remove-Item $cfg
	} Else {
		Write-Host "No existing configuration found for $reqHostFQDN."
	}
	Write-Host "*****[INFO] Creating '$reqHostFQDN' config file"
	New-Item $cfg -type file -value $content

}

Function createCsr {
	Param(
		[parameter(Mandatory=$true)][String]$reqWD,
		[parameter(Mandatory=$true)][String]$reqHostFQDN,
		[parameter(Mandatory=$true)]$reqHostKey
	)
	
	[String]$csr = $reqWD + "/" + $reqHostFQDN + ".csr"
	If (Test-Path -Path $csr) {
		Write-Host "Found existing certificate request, deleting."
		Remove-Item $csr
	} Else {
		Write-Host "No existing certificate request found."
	}
	openssl.exe req -new -config $reqWD/config.cfg -key $reqHostKey -out $reqWD/$reqHostFQDN.csr
}

Function addNewHostCsv {
	Param(
		[parameter(Mandatory=$true)][Int]$index,
		[parameter(Mandatory=$true)][String]$DNS1,
		[parameter(Mandatory=$false)][String]$Domain,
		[parameter(Mandatory=$false)][String]$IP,
		[parameter(Mandatory=$false)][String]$FileName,
		[parameter(Mandatory=$false)]$RID,
		[parameter(Mandatory=$false)]$err
	)
	
	New-Object PsObject -property @{
		'Name' = 'ESXi Host ' + $index
		'DNS1' = $DNS1
		'Domain' = $Domain
		'IPAddress' = $IP
		'FileName' = $FileName
		'RID' = $RID
		'Error' = errHandler $err -vsh $FileName
	}
}

$requiredCmdList = @('openssl.exe')

ForEach ($cmd in $requiredCmdList) {
	$cmdTestResult = Test-Command $cmd
	If ($cmdTestResult -and $cmdTestResult -match "^\d+$") {
		errHandler $cmdTestResult -cmd $cmd
	}
}

# Define directory containing master host CSV file and individual host directories containing signed certificates and keys
$stepHostCsv = 0
While ($stepHostCsv -eq 0) {
    errHandler 901
    $vshCsvDir = Read-Host
    If ($vshCsvDir -ne "") {
        $hostCsvFile = $vshCsvDir + 'hostcsv.csv'
        If ((Test-Path $hostCsvFile) -contains $true) {
            errHandler 101
            $stepHostCsv = 1
        } Else {
            errHandler 102
            $stepHostCsv = 0
        }
    } Else {
        errHandler 103
        Break
    }
}

# Read in master host CSV file
$arrVshCsv = Import-Csv $hostCsvFile

# Get individual host directories containing signed certificates and keys
$arrCsrDirs = Get-ChildItem $vshCsvDir | Where-Object {$_.PSIsContainer} | Foreach-Object {$_.Name}

$csrReadyDir = $vshCsvDir + "CSR_Ready"
$curDate = Get-Date -UFormat "%Y%m%d%H%M"
$newCsvResultSet = @()
$stepHostOp = 0
$writeNewHostCsv = 0

$rnHostCsvFile = Test-FileOpen($hostCsvFile)
If ($rnHostCsvFile -eq $true) {
	errHandler 115
}

ForEach ($objVsh in $arrVshCsv) {
	$stepHostOp = $stepHostOp + 1
	$vshNB = $($objVsh.DNS1)
	$vshDM = $($objVsh.Domain)
	$vshWD = $($objVsh.FileName)
	$vshIP = $($objVsh.IPAddress)
	
	If ($vshNB -notmatch [regex]::Escape($vshDM) + '$') {
		$vshAddr = $vshNB + '.' + $vshDM
	} Else {
		$vshAddr = $vshNB
	}

	If ($($objVsh.RID) -match "^\d+$") {
		[int]$vshRN = $($objVsh.RID)
	} Else {
		If ($writeNewHostCsv -eq 0) {
			$writeNewHostCsv = 1
		}
		Write-Host "ERROR: Request ID for host $vshAddr is not numeric, skipping." -BackgroundColor Red -ForegroundColor White
		$newCsvResultSet += addNewHostCsv -index $stepHostOp -DNS1 $vshNB -Domain $vshDM -IP $vshIP -FileName $vshWD -RID $vshRN -err 906
		Continue
	}
	
	If ($vshWD -in $arrCsrDirs) {
		$workDir = $vshCsvDir + $vshWD + '\'
		$cerl = $workDir + $vshWD + ".cer"
		$peml = $workDir + $vshWD + ".key"
		$csrl = $workDir + $vshWD + ".csr"
		
		If (Test-Path -Path $cerl -PathType Leaf) {
			$cerExists = $true
		} Else {
			$cerExists = $false
			# errHandler 109 -vsh $vshAddr
			# $newCsvResultSet += addNewHostCsv -index $stepHostOp -DNS1 $vshNB -Domain $vshDM -IP $vshIP -FileName $vshWD -RID $vshRN -err 109
		}
	
		
		If (Test-Path -Path $peml -PathType Leaf) {
			If ($cerExists -eq $true) {
				$keyHash = openssl.exe rsa -in $peml -noout -modulus | openssl.exe md5
				$cerHash = openssl.exe x509 -in $cerl -noout -modulus | openssl.exe md5
				$keyPairTest = testCertKeyPair -testCert $cerHash -testKey $keyHash
				If ($keyPairTest -eq $false) {
					If ($writeNewHostCsv -eq 0) {
						$writeNewHostCsv = 1
					}
					errHandler 905 -vsh $vshAddr
					$newCsvResultSet += addNewHostCsv -index $stepHostOp -DNS1 $vshNB -Domain $vshDM -IP $vshIP -FileName $vshWD -RID $vshRN -err 905
					Continue
				}
			}
			createConfig -requestID $vshRN -reqWD $workDir -reqHostFQDN $vshAddr
			createCsr -reqWD $workDir -reqHostFQDN $vshAddr -reqHostKey $peml
			If (Test-Path -Path $csrReadyDir) {
				$csrfile = $workDir + $vshAddr + ".csr"
				Copy-Item $csrfile -Destination $csrReadyDir
			}
		} Else {
			If ($writeNewHostCsv -eq 0) {
				$writeNewHostCsv = 1
			}
			errHandler 109 -vsh $vshAddr
			$newCsvResultSet += addNewHostCsv -index $stepHostOp -DNS1 $vshNB -Domain $vshDM -IP $vshIP -FileName $vshWD -RID $vshRN -err 109
			Continue
		}
	} Else {
		If ($writeNewHostCsv -eq 0) {
			$writeNewHostCsv = 1
		}
		errHandler 110 -vsh $vshAddr
		$newCsvResultSet += addNewHostCsv -index $stepHostOp -DNS1 $vshNB -Domain $vshDM -IP $vshIP -FileName $vshWD -RID $vshRN -err 110
		Continue
	}
}

$oldHostCsvFile = $vshCsvDir + "/hostcsv.csv." + $curDate + ".old"
Rename-Item -Path $hostCsvFile -NewName $oldHostCsvFile

If ($writeNewHostCsv = 1) {
	$newCsvResultSet | Export-Csv $hostCsvFile
}
