# push notification messages enabled ?
Invoke-WebRequest -Uri "https://adrisupport.000webhostapp.com/UCP/index.php" -OutFile "UCP.html"
$Source = Get-Content -path UCP.html -raw

# send telegram notification
$Source -match '<td><b>telegram</b></td><td>(.*?)</td>'
$telegram = $matches[1]

if ( $telegram -eq "ON" )
{
	Function Send-Telegram {
        Param([Parameter(Mandatory=$true)][String]$Message)
        $Telegramtoken = "$env:TELEGRAM"
        $Telegramchatid = "$env:CHAT_ID"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	$Response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($Telegramtoken)/sendMessage?chat_id=$($Telegramchatid)&text=$($Message)"}
	
	Send-Telegram -Message "[UCP-debug] Test sending message on telegram"
	} else {
	echo "Telegram not enabling"
}