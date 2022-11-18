If ($LastExitCode -eq 0) {
	# git and create tag
	git config --local user.email "a-d-r-i@outlook.fr"
	git config --local user.name "A-d-r-i"
	git add .
	git commit -m "[Bot] Update files - $id"
	git tag -a $id-v$tag -m "$name - version $tag"
	git push -f && git push --tags
	
	# create release
	Install-Module -Name New-GitHubRelease -Force
	Import-Module -Name New-GitHubRelease
	$newGitHubReleaseParameters = @{
		GitHubUsername = "A-d-r-i"
		GitHubRepositoryName = "update_choco_packages"
		GitHubAccessToken = "$env:ACTIONS_TOKEN"
		ReleaseName = "$name v$tag"
		TagName = "$id-v$tag"
		ReleaseNotes = "$release"
		AssetFilePaths = ".\$id\$id.$tag.nupkg"
		IsPreRelease = $false
		IsDraft = $false
	}
	$resultrelease = New-GitHubRelease @newGitHubReleaseParameters
	
	# Provide some feedback
	if ($result.Succeeded -eq $true)
	{
		Write-Output "Release published successfully! View it at $($result.ReleaseUrl)"
	}
	elseif ($result.ReleaseCreationSucceeded -eq $false)
	{
		Write-Error "The release was not created. Error message is: $($result.ErrorMessage)"
	}
	elseif ($result.AllAssetUploadsSucceeded -eq $false)
	{
		Write-Error "The release was created, but not all of the assets were uploaded to it. View it at $($result.ReleaseUrl). Error message is: $($result.ErrorMessage)"
	}
	
	# push notification messages enabled ?
	Invoke-WebRequest -Uri "https://adrisupport.000webhostapp.com/UCP/index.php" -OutFile "UCP.html"
	$Source = Get-Content -path UCP.html -raw
	
	# post twitter tweet
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
		Send-TwitterStatuses_Update -status "$name v$tag push now on @chocolateynuget! 
		
		Link: https://community.chocolatey.org/packages/$id/$tag
		$accounts
		$tags #release #opensource
		"
		} else {
		echo "Twitter not enabling"
	}
	
	# send telegram notification
	$Source -match '<td><b>telegram</b></td><td>(.*?)</td>'
	$telegram = $matches[1]
	
	if ( $telegram -eq "ON" )
	{
		$tmtext = "[UCP] New update of $name : $tag - https://community.chocolatey.org/packages/$id/$tag"
		$tmtoken = "$env:TELEGRAM"
		$tmchatid = "$env:CHAT_ID"
		Invoke-RestMethod -Uri "https://api.telegram.org/bot$tmtoken/sendMessage?chat_id=$tmchatid&text=$tmtext"
		} else {
	echo "Telegram not enabling"}
	
	
	# post mastodon toot
	$Source -match '<td><b>mastodon</b></td><td>(.*?)</td>'
	$mastodon = $matches[1]
	
	if ( $mastodon -eq "ON" )
	{
		$mastodonheaders = @{Authorization = "Bearer $env:MASTODON"}
		$mastodonform = @{status = "$name v$tag push now on @chocolateynuget@twitter.com! 
			
			Link: https://community.chocolatey.org/packages/$id/$tag
		$tags #release #opensource"}
		Invoke-WebRequest -Uri "https://piaille.fr/api/v1/statuses" -Headers $mastodonheaders -Method Post -Form $mastodonform
		} else {
	echo "Mastodon not enabling"}
	
	} else {
	echo "Error in choco push - Exit code: $LastExitCode "
}
