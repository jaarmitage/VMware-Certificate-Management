Function errHandler {
    Param(
        [parameter(Position=0,Mandatory=$true)][int]$errNo,
        [parameter(Mandatory=$false)][string]$vsh,
        [parameter(Mandatory=$false)][int]$ctr,
        [parameter(Mandatory=$false)][int]$rcxt,
        [parameter(Mandatory=$false)][string]$cmd
    )
    Switch ($errNo) {
        101 {"OK: Host CSV file (hostcsv.csv) found."; Break}
        104 {"ERROR: Host $vsh is not properly connected in vCenter Server."; Break}
        105 {"INFO: Host $vsh is already in maintenance mode. Proceeding."; Break}
        111 {"INFO: Host $vsh is already connected and not in maintenance mode. Proceeding."; Break}
        801 {"Putting host $vsh into maintenance mode."; Break}
        802 {"Starting SSH service on host $vsh."; Break}
        803 {"Initiating SSH session with host $vsh."; Break}
        804 {"Backing up old CA store."; Break}
        805 {"Transferring new certificate files to host $vsh."; Break}
        809 {"Closing SSH connection to host $vsh."; Break}
        810 {"Stopping SSH service on host $vsh."; Break}
        812 {"Removing host $vsh from maintenance mode."; Break}
        1001 {"NSX endpoint connection specification found."; Break}
        1002 {"NSX endpoint connection specification not found."; Break}
    }
}