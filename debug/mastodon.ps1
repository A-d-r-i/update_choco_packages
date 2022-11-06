# push notification messages enabled ?
Invoke-WebRequest -Uri "https://adrisupport.000webhostapp.com/UCP/index.php" -OutFile "UCP.html"
$Source = Get-Content -path UCP.html -raw

# post mastodon toot
$Source -match '<td><b>mastodon</b></td><td>(.*?)</td>'
$mastodon = $matches[1]

if ( $mastodon -eq "ON" )
{
	$mastodonheaders = @{Authorization = "Bearer $env:MASTODON"}
	$mastodonform = @{status = "[UCP-debug] Test sending message on mastodon"}
	Invoke-WebRequest -Uri "https://piaille.fr/api/v1/statuses" -Headers $mastodonheaders -Method Post -Form $mastodonform
	} else {
	echo "Mastodon not enabling"
}
