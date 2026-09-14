If ($LastExitCode -eq 0) {
	# git and create tag
	git config user.name 'github-actions[bot]'
	git config user.email 'github-actions[bot]@users.noreply.github.com'
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
	$resultrelease.ErrorMessage
	
	} else {
	echo "Error in choco push - Exit code: $LastExitCode "
}
