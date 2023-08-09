for ($i = 1; $1 -le 254; $i++)
{
$ip = "10.XX.0.$i"
if (Test-Connection $ip -Quiet -Count 1)
{
	Write-output "$ip is reachable"
}
}
