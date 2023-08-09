$ws = read-host -Prompt "QBC-WSXX?"

Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName qbc-ws$ws | Select-Object -Property DeviceID,@{'Name' = 'FreeSpace (GB)'; Expression= { [int]($_.FreeSpace / 1GB) }},@{'Name' = 'Total size (GB)'; Expression= { [int]($_.size / 1GB) }},@{'Name' = '% Free'; Expression = {([int]($_.FreeSpace / 1GB) /  [int]($_.size / 1GB)).tostring("P")}}
