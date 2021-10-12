$tag = (Invoke-WebRequest "https://api.github.com/repos/OpenAcousticDevices/AudioMoth-Configuration-App/releases/latest" | ConvertFrom-Json)[0].name
$release = (Invoke-WebRequest "https://api.github.com/repos/OpenAcousticDevices/AudioMoth-Configuration-App/releases/latest" | ConvertFrom-Json)[0].body

$file = "./audiomoth-config/audiomoth-config.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://github.com/OpenAcousticDevices/AudioMoth-Configuration-App/releases/download/$tag/AudioMothConfigurationAppSetup$tag.exe" -OutFile "./audiomoth-config/tools/AudioMothConfigurationAppSetup.exe"

choco pack ./audiomoth-config/audiomoth-config.nuspec --outputdirectory .\audiomoth-config

If ($LastExitCode -eq 0) {
	choco push ./audiomoth-config/audiomoth-config.$tag.nupkg --source https://push.chocolatey.org/
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}

If ($LastExitCode -eq 0) {

#git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - audiomoth-config" --allow-empty
git tag -a audiomoth-config-v$tag -m "Audiomoth Config - version $tag"
git push -f && git push --tags

#create release
Install-Module -Name New-GitHubRelease -Force
Import-Module -Name New-GitHubRelease
$newGitHubReleaseParameters = @{
GitHubUsername = "A-d-r-i"
GitHubRepositoryName = "update_choco_package"
GitHubAccessToken = "$env:ACTIONS_TOKEN"
ReleaseName = "Audiomoth Config v$tag"
TagName = "audiomoth-config-v$tag"
ReleaseNotes = "$release"
AssetFilePaths = ".\audiomoth-config\audiomoth-config.$tag.nupkg"
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
Send-TwitterStatuses_Update -status "Audiomoth-Config-App v$tag push now on @chocolateynuget! 

Link: https://community.chocolatey.org/packages/audiomoth-config/$tag
@AudioMoth @OpenAcoustics
#audiomoth #release #opensource
"
}
} else {
	echo "Error in choco push - Exit code: $LastExitCode "
}
