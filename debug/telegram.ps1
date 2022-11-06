# push notification messages enabled ?
Invoke-WebRequest -Uri "https://adrisupport.000webhostapp.com/UCP/index.php" -OutFile "UCP.html"
$Source = Get-Content -path UCP.html -raw

# send telegram notification
$Source -match '<td><b>telegram</b></td><td>(.*?)</td>'
$telegram = $matches[1]

if ( $telegram -eq "ON" )
{
        $tmtext = "[UCP-debug] Test sending message on telegram"
	$tmtoken = "$env:TELEGRAM"
        $tmchatid = "$env:CHAT_ID"
	Invoke-RestMethod -Uri "https://api.telegram.org/bot$tmtoken/sendMessage?chat_id=$tmchatid&text=$tmtext"}
	} else {
	echo "Telegram not enabling"
}
