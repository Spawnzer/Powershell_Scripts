
Import-Module PSWriteHTML.psd1 -Force

class Proxmox{
    [string]$response
}
class Esxi{
    [string]$token = "Basic XXXX"
    [string]$baseUrl = "https://qbc-XXXX/"
}

class Pfsense {
    [System.Collections.ArrayList]$Wangw = @("WANGW","XXXX")
    [System.Collections.ArrayList]$XXXX = @("XXXX","")
    [string]$Address = "XXXX"
}

class PaloAlto {
    [xml]$keyPalo
    [string]$Sid
    [string]$SidUrl = "https:/XXXX//api/?type=op&cmd=<show><system><info></info></system></show>&key="
    [string]$Address = "https://qbc-XXXX/"
    [System.Collections.ArrayList]$Datum
}

class Fs1 {
    [int]$used = 0
    [xml]$req
    [string]$sid
    [System.Collections.ArrayList]$dir
    [string]$url = "http://XXXX:8080/cgi-bin/filemanager/utilRequest.cgi?func=get_file_size&sid="+$Fs1.sid+"&path="
    [string]$size = "63 TB"
    [string]$address = "https://XXXX/cgi-bin/"
}

class Fs2{
    [string]$sid
    [string]$url
    [string]$address = "https://XXXX:5001/"
    [int]$free
    [int]$total
    [int]$used
    [System.Object]$data
}

#Initiate Classes for the different plateforms
    $Pfsense = New-Object -TypeName Pfsense
    $PaloAlto = New-Object -TypeName PaloAlto
    $Fs2 = New-Object -TypeName Fs2
    $Fs1 = New-Object -TypeName Fs1

#Get keys for API calls and build url to get the relevant data

    #PaloAlto
    $PaloAlto.keyPalo = Invoke-RestMethod -uri "https://XXXX/api/?type=keygen&user=XXXX&password=XXXX!" -SkipCertificateCheck
    $PaloAlto.SidUrl += [string]$PaloAlto.keyPalo.response.result.key
    #Fileserver2-qc
    $Fs2.sid = (Invoke-RestMethod -Uri "https://XXXX:5001/webapi/auth.cgi?api=SYNO.API.Auth&version=3&method=login&account=XXXX&passwd=XXXX&session=FileStation&format=cookie" -SkipCertificateCheck).data.sid
    $Fs2.url = "https://XXXX:5001/webapi/entry.cgi?api=SYNO.FileStation.List&version=2&method=list_share&additional=%5B%22volume_status%22%2C%22owner%2Ctime%22%5D&_sid="+$Fs2.sid
    #Fileserver1-qc
    [xml]$req = (Invoke-WebRequest "http://XXXX/cgi-bin/authLogin.cgi?user=Monitor&plain_pwd=XXXX&remme=1")
    $sid = $req.QDocRoot.authSid.'#cdata-section'
    $Fs1.dir = (invoke-restmethod -uri "http://XXXX/cgi-bin/filemanager/utilRequest.cgi?func=get_tree&sid=$sid&node=share_root").id.replace('/','')


#load selected images from current directory
    $img = @('.\41v09y9lP0L._AC_UL600_SR600,600_.jpg','.\EeTMYIIXkAcSzE1.png', '.\63bb9yahccaa.jpg' , '.\deadge.jpg')

#Calculate for Fileserver1-qc 
  <#  foreach ($folder in $Fs1.dir){
        $str = ""
        $subfolds = (invoke-restmethod -uri "http://XXXX:8080/cgi-bin/filemanager/utilRequest.cgi?func=get_tree&sid=$sid&node=$folder").id.replace($folder,'&name=')
        $wc = ($subfolds | Measure-Object).Count
        foreach ($fold in $subfolds){
            $str += $fold.replace($folder,'&name=')
        }
        $call = $Fs1.url + $folder+ "&total=$wc" + $str
        $u += (Invoke-RestMethod $call).size
        }
    $fs1Size = $u / 1tb #>

while (1){

    #initiate variables
        $down=[System.Collections.ArrayList]@()
    
    #Gather Data from the APIs
        $fs2.data = Invoke-RestMethod -Uri $Fs2.url -SkipCertificateCheck
        [xml]$data = Invoke-WebRequest -Uri $PaloAlto.SidUrl -SkipCertificateCheck
        $DataPalo = select-xml -xml $data  -XPath "response/result/IPSec" | Select-Object -ExpandProperty Node

    #Calculation for Fileserver2-qc
        $Fs2.free = $fs2.data.data.shares[0].additional.volume_status.freespace / 1000Gb
        $Fs2.total = $fs2.data.data.shares[0].additional.volume_status.totalspace / 1000Gb
        #$freespace = "{0:n2}" -f ($Fs2.free) #not currently in us
        $totalspace = "{0:n2} TB" -f ($Fs2.total)
        $Fs2.used = $Fs2.total - $Fs2.free
        $usedspace = "{0:n2} TB" -f ($Fs2.used)#>

    #Populate Palo Alto struct with data recovered during API call
        $PaloAlto.Datum =  foreach ($studio in $DataPalo){$studio.ChildNodes | Select-Object -Property name, state}

    #Generate display page
    New-HTML -TitleText $Title -Online -FilePath $PSScriptRoot\Example14.html -AutoRefresh 60{
        New-HTMLSection -HeaderText $(get-date) {   
            New-HTMLStatus {
                if (Test-Connection -count 1 $Pfsense.WANGW[1]){
                    $down.Add($Pfsense.Address)
                    New-HTMLStatusItem -ServiceName $Pfsense.WANGW[0] -ServiceStatus 'Operational' -Icon Good -Percentage '100%'
                }
                else {
                    New-HTMLStatusItem -ServiceName $Pfsense.WANGW[0] -ServiceStatus 'Non-functional' -Icon Dead -Percentage '0%'
                    $down.Add($Pfsense.Address)
                }
                if (Test-Connection -count 1 $Pfsense.XXXX[1]){
                    New-HTMLStatusItem -ServiceName $Pfsense.XXXX[0] -ServiceStatus 'Operational' -Icon Good -Percentage '100%'
                }
                else {
                    New-HTMLStatusItem -ServiceName $Pfsense.XXXX[0] -ServiceStatus 'Non-functional' -Icon Dead -Percentage '0%'
                    $down.Add($Pfsense.Address)
                }#>
                <#if ($PaloAlto.Datum[0].state -eq 'active'){
                    New-HTMLStatusItem -ServiceName $PaloAlto.Datum[0].name -ServiceStatus 'Operational' -Icon Good -Percentage '100%'
                }
                else {
                    New-HTMLStatusItem -ServiceName $PaloAlto.Datum[0].name -ServiceStatus 'Non-functional' -Icon Dead -Percentage '0%'
                    $down.Add($PaloAlto.Address)
                }
                if ($PaloAlto.Datum[1].state -eq 'active'){
                    New-HTMLStatusItem -ServiceName $PaloAlto.Datum[1].name -ServiceStatus 'Operational' -Icon Good -Percentage '100%'
                }
                else {
                    New-HTMLStatusItem -ServiceName $PaloAlto.Datum[1].name -ServiceStatus 'Non-functional' -Icon Dead -Percentage '0%'
                    $down.Add($PaloAlto.Address)
                }#>
                if ($Fs2.free -gt 10 )
                {
                    $down.Add("https://XXXX:5001/")
                    New-HTMLStatusItem -ServiceName "XXXX-qc $usedspace / $totalspace" -ServiceStatus 'Operational' -Icon Good -Percentage '100%' 
                }
                else {
                    New-HTMLStatusItem -ServiceName  "XXXX-qc $usedspace / $totalspace" -ServiceStatus 'Non-functional' -Icon Dead -Percentage '0%'
                }
                <#if ($Fs2.free -gt 10 )
                {
                    $down.Add($Fs1.address)
                    New-HTMLStatusItem -ServiceName "XXXX-qc $fs1Size / 63 TB" -ServiceStatus 'Operational' -Icon Good -Percentage '100%' 
                }
                else {
                    New-HTMLStatusItem -ServiceName "XXXX-qc $fs1Size / 63 TB" -ServiceStatus 'Non-functional' -Icon Dead -Percentage '0%' 
                }#>
                foreach ($site in $down) {
                    New-HTMLImage -Source $img[(0..3 | Get-Random)] -UrlLink $site -Width 100 -Height 100
                }
            
            }
        }
    } -ShowHTML 
    Start-Sleep -seconds 50
}

