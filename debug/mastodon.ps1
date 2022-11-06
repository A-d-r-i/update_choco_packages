# push notification messages enabled ?
Invoke-WebRequest -Uri "https://adrisupport.000webhostapp.com/UCP/index.php" -OutFile "UCP.html"
$Source = Get-Content -path UCP.html -raw

# post mastodon toot
$Source -match '<td><b>mastodon</b></td><td>(.*?)</td>'
$mastodon = $matches[1]

if ( $mastodon -eq "ON" )
{
	$Uri = 'https://piaille.fr/api/v1/statuses'
	$headers = @{
		Authorization = "Bearer $env:MASTODON"
	}
	$form = @{
		status = "Here we are on Mastodon! In order to avoid overloading @A_d_r_i@piaille.fr's account, it was decided to create a separate account for update_choco_packages.

Find us on:

Github: https://github.com/A-d-r-i/update_choco_packages

Twitter: @up_choco_pack@twitter.com ( https://twitter.com/up_choco_pack )"
	}
	Invoke-WebRequest -Uri $Uri -Headers $headers -Method Post -Form $form
	} else {
	echo "Mastodon not enabling"
}
