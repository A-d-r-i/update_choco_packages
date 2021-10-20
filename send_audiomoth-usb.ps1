$tag = (Invoke-WebRequest "https://api.github.com/repos/OpenAcousticDevices/AudioMoth-USB-Microphone-App/releases/latest" | ConvertFrom-Json)[0].name
$release = (Invoke-WebRequest "https://api.github.com/repos/OpenAcousticDevices/AudioMoth-USB-Microphone-App/releases/latest" | ConvertFrom-Json)[0].body

$file = "./audiomoth-usb/audiomoth-usb.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://github.com/OpenAcousticDevices/AudioMoth-USB-Microphone-App/releases/download/$tag/AudioMothUSBMicrophoneAppSetup$tag.exe" -OutFile "./audiomoth-usb/tools/AudioMothUSBMicrophoneAppSetup$tag.exe"

choco pack ./audiomoth-usb/audiomoth-usb.nuspec --outputdirectory .\audiomoth-usb

If ($LastExitCode -eq 0) {
	choco push ./audiomoth-usb/audiomoth-usb.$tag.nupkg --source https://push.chocolatey.org/
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}

If ($LastExitCode -eq 0) {

#git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - audiomoth-usb" --allow-empty
git tag -a audiomoth-usb-v$tag -m "Audiomoth USB Microphone - version $tag"
git push -f && git push --tags

#create release
Install-Module -Name New-GitHubRelease -Force
Import-Module -Name New-GitHubRelease
$newGitHubReleaseParameters = @{
GitHubUsername = "A-d-r-i"
GitHubRepositoryName = "update_choco_package"
GitHubAccessToken = "$env:ACTIONS_TOKEN"
ReleaseName = "Audiomoth USB Microphone v$tag"
TagName = "audiomoth-usb-v$tag"
ReleaseNotes = "$release"
AssetFilePaths = ".\audiomoth-usb\audiomoth-usb.$tag.nupkg"
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
Send-TwitterStatuses_Update -status "Audiomoth-USB-Microphone-App v$tag push now on @chocolateynuget! 

Link: https://community.chocolatey.org/packages/audiomoth-usb/$tag
@AudioMoth @OpenAcoustics
#audiomoth #release #opensource
"
}
} else {
	echo "Error in choco push - Exit code: $LastExitCode "
}
