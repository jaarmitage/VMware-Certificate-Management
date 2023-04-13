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