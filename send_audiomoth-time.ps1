$tag = (Invoke-WebRequest "https://api.github.com/repos/OpenAcousticDevices/AudioMoth-Time-App/releases/latest" | ConvertFrom-Json)[0].name
$release = (Invoke-WebRequest "https://api.github.com/repos/OpenAcousticDevices/AudioMoth-Time-App/releases/latest" | ConvertFrom-Json)[0].body

$file = "./audiomoth-time/audiomoth-time.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://github.com/OpenAcousticDevices/AudioMoth-Time-App/releases/download/$tag/AudioMothTimeAppSetup$tag.exe" -OutFile "./audiomoth-time/tools/AudioMothTimeAppSetup.exe"

choco pack ./audiomoth-time/audiomoth-time.nuspec --outputdirectory .\audiomoth-time

If ($LastExitCode -eq 0) {
	choco push ./audiomoth-time/audiomoth-time.$tag.nupkg --source https://push.chocolatey.org/
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}

If ($LastExitCode -eq 0) {

#git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - audiomoth-time" --allow-empty
git tag -a audiomoth-time-v$tag -m "Audiomoth Time - version $tag"
git push -f && git push --tags

#create release
Install-Module -Name New-GitHubRelease -Force
Import-Module -Name New-GitHubRelease
$newGitHubReleaseParameters = @{
GitHubUsername = "A-d-r-i"
GitHubRepositoryName = "update_choco_package"
GitHubAccessToken = "$env:ACTIONS_TOKEN"
ReleaseName = "Audiomoth Time v$tag"
TagName = "audiomoth-time-v$tag"
ReleaseNotes = "$release"
AssetFilePaths = ".\audiomoth-time\audiomoth-time.$tag.nupkg"
IsPreRelease = $false
IsDraft = $false
}
$resultrelease = New-GitHubRelease @newGitHubReleaseParameters

#post tweet
$twitter = (Select-String -Path config.txt -Pattern "twitter=(.*)").Matches.Groups[1].Value
if ( $twitter -eq "y" )
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
Send-TwitterStatuses_Update -status "Audiomoth-Time-App v$tag push now on @chocolateynuget! 

Link: https://community.chocolatey.org/packages/audiomoth-time/$tag
@AudioMoth @OpenAcoustics
#audiomoth #release #opensource
"
}
} else {
	echo "Error in choco push - Exit code: $LastExitCode "
}
