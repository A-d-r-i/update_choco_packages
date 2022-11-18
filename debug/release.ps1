$name = "Demopackage"
$release = "Test of release creation"
$id = "demopackage"
$tag = "0.0.1"

Install-Module -Name New-GitHubRelease -Force
	Import-Module -Name New-GitHubRelease
	$newGitHubReleaseParameters = @{
		GitHubUsername = "A-d-r-i"
		GitHubRepositoryName = "update_choco_packages"
		GitHubAccessToken = "$env:ACTIONS_TOKEN"
		ReleaseName = "$name v$tag"
		TagName = "$id-v$tag"
		ReleaseNotes = "$release"
		AssetFilePaths = ".\debug\$id\$id.$tag.txt"
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
