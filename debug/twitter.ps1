# push notification messages enabled ?
Invoke-WebRequest -Uri "https://adrisupport.000webhostapp.com/UCP/index.php" -OutFile "UCP.html"
$Source = Get-Content -path UCP.html -raw

# post tweet
$Source -match '<td><b>twitter</b></td><td>(.*?)</td>'
$twitter = $matches[1]

if ( $twitter -eq "ON" )
{
	Install-Module PSTwitterAPI -Force
	Import-Module PSTwitterAPI
	$OAuthSettings = @{
		ApiKey = "$env:PST_KEY"
		ApiSecret = "$env:PST_SECRET"
		AccessToken = "$env:PST_TOKEN"
		AccessTokenSecret = "$env:PST_TOKEN_SECRET"
	}
	Set-TwitterOAuthSettings @OAuthSettings
	Send-TwitterStatuses_Update -status "Test sending message on twitter"
	} else {
	echo "Twitter not enabling" 
}
