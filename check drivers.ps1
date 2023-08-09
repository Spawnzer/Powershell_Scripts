$ws = read-host -Prompt "QBC-WSXX?"


Get-CimInstance -ClassName Win32_SystemDriver -ComputerName qbc-ws$ws | Select-Object -Property Name,Status | Where-Object {$_.Status -notlike "ok"}