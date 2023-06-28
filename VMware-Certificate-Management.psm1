$VmwCMPrivate = @(
    Get-ChildItem -Path $PSScriptRoot -Filter '*.util.ps1' -Recurse
)
$VmwCMPublic = @(
    Get-ChildItem -Path $PSScriptRoot -Filter '*.ps1' -Exclude '*.util.ps1','*.test.ps1' -Recurse
)

Write-Verbose "Importing functions."
ForEach ($import in @($VmwCMPrivate + $VmwCMPublic)) {
    Try {
        Write-Verbose "Processing $import.FullName"
        . $import.FullName
    } Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function $VmwCMPublic.Basename