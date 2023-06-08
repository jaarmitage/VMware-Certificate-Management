$VmwCMPublic = @(
    Get-ChildItem -Path $PSScriptRoot\vSphere-Certificate-Management\*.pub.ps1 -ErrorAction SilentlyContinue
    Get-ChildItem -Path $PSScriptRoot\NSX-Certificate-Management\*.pub.ps1 -ErrorAction SilentlyContinue
)
$VmwCMPrivate = @(
    Get-ChildItem -Path $PSScriptRoot\vSphere-Certificate-Management\*.priv.ps1 -ErrorAction SilentlyContinue
)

ForEach ($import in @($VmwCMPublic + $VmwCMPrivate)) {
    Try {
        . $import.FullName
    } Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function $VmwCMPublic.Basename