 for ($i = 1; $i -le 115; $i++) {
 	if ($i -lt 10) {
 		$ws = "QBC-WS0$i"
	 }
	 else {
		 $ws = "QBC-WS$i"
	 }

	try {
		$gpu = Get-CimInstance -ClassName CIM_VideoController -ComputerName $ws -ErrorAction 'silentlycontinue'
		if ($gpu) {
			Write-Output -Verbose "$ws - $($gpu.VideoProcessor)"
		}
	}
	catch{}
}