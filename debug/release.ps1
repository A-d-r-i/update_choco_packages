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
		AssetFilePaths = ".\$id\$id.$tag.nupkg"
		IsPreRelease = $false
		IsDraft = $false
	}
	$resultrelease = New-GitHubRelease @newGitHubReleaseParameters
	$resultrelease.ErrorMessage