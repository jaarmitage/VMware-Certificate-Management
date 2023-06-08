$VmwCMPublic = @(
    #Get-ChildItem -Path $PSScriptRoot\MainFunctions.ps1 -ErrorAction SilentlyContinue
    Get-ChildItem -Path $PSScriptRoot -Filter '*.ps1' -Exclude '*.util.ps1','*.test.ps1' -Recurse
)
$VmwCMPrivate = @(
    #Get-ChildItem -Path $PSScriptRoot\common.ps1 -ErrorAction SilentlyContinue
    #Get-ChildItem -Path $PSScriptRoot\errorHandler.ps1 -ErrorAction SilentlyContinue
    #Get-ChildItem -Path $PSScriptRoot\vSphere-Certificate-Management\*.util.ps1 -ErrorAction SilentlyContinue
    Get-ChildItem -Path $PSScriptRoot -Filter '*.util.ps1' -Recurse
)

Write-Verbose "Importing functions."
ForEach ($import in @($VmwCMPublic + $VmwCMPrivate)) {
    Try {
        Write-Verbose "Processing $import.FullName"
        . $import.FullName
    } Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function $VmwCMPublic.Basename