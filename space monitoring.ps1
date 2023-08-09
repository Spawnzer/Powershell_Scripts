for ($i = 1; $i -le 105; $i++) 
 {
	 $ws = if ($i -lt 10) {"QBC-WS0$i" } else {"QBC-WS$i"}
    try 
    {
        $list = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $ws -ErrorAction:SilentlyContinue | Select-Object -Property DeviceID
        foreach ($disk in $list -replace '@{DeviceID=','')
        {
            $disks = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $ws | Select-Object -Property DeviceID, FreeSpace, size | Where DeviceID -eq $disk.trimend("}")
            if($disks.size)
            {
                $used = (([int]($disks.size / 1GB) - [int]($disks.FreeSpace / 1GB)) / [int]($disks.size / 1GB))
                if (($used -gt 0.9) -and !($disk.trimend("}") -like "P:"))
                {
                    $res = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $ws | Select-Object -Property DeviceID,@{'Name' = 'FreeSpace (GB)'; Expression= { [int]($_.FreeSpace / 1GB) }},@{'Name' = 'Total size (GB)'; Expression= { [int]($_.size / 1GB) }},@{'Name' = '% used'; Expression = {(([int]($_.size / 1GB) - [int]($_.FreeSpace / 1GB)) / [int]($_.size / 1GB)).tostring("P")}}
                    write-output >> C:\Users\alexandre.dubeau\Desktop\Scripts\log\$(Get-date -format "yyyy-MM-dd").txt $ws
                    write-output >> C:\Users\alexandre.dubeau\Desktop\Scripts\log\$(Get-date -format "yyyy-MM-dd").txt $res
                    continue
                }
            }
        }
    }
    catch{}
}