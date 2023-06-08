Function Test-Command {
	Param(
		[parameter(Mandatory=$true)][String]$command
	)
	
	$oldErrActPref = $ErrorActionPreference
	$ErrorActionPreference = 'stop'
	
	Try {
		If (Get-Command $command) {
			Return 114
		}
	} Catch {
		Return 113
	} Finally {
		$ErrorActionPreference = $oldErrActPref
	}
}
