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
	Send-TwitterStatuses_Update -status "Here we are on Twitter! In order to avoid overloading @Ad_r_i's account, it was decided to create a separate account for update_choco_packages.

Find us on:

@joinmastodon: @update_choco_packages@piaille.fr ( https://piaille.fr/@update_choco_packages )

@github: https://github.com/A-d-r-i/update_choco_packages"
	} else {
	echo "Twitter not enabling" 
}
