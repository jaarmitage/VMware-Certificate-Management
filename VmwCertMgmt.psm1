$VmwCMPublic = @(
    Get-ChildItem -Path $PSScriptRoot\MainFunctions.ps1 -ErrorAction SilentlyContinue
    Get-ChildItem -Path $PSScriptRoot\vSphere-Certificate-Management\*.cmd.ps1 -ErrorAction SilentlyContinue
    Get-ChildItem -Path $PSScriptRoot\NSX-Certificate-Management\*.cmd.ps1 -ErrorAction SilentlyContinue
)
$VmwCMPrivate = @(
    Get-ChildItem -Path $PSScriptRoot\common.ps1 -ErrorAction SilentlyContinue
    Get-ChildItem -Path $PSScriptRoot\errorHandler.ps1 -ErrorAction SilentlyContinue
    Get-ChildItem -Path $PSScriptRoot\vSphere-Certificate-Management\*.util.ps1 -ErrorAction SilentlyContinue
    Get-ChildItem -Path $PSScriptRoot\NSX-Certificate-Management\*.util.ps1 -ErrorAction SilentlyContinue
)

ForEach ($import in @($VmwCMPublic + $VmwCMPrivate)) {
    Try {
        . $import.FullName
    } Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function $VmwCMPublic.Basename