# extract latest version and release
$tag = (Invoke-WebRequest "https://api.github.com/repos/OpenAcousticDevices/AudioMoth-Configuration-App/releases/latest" | ConvertFrom-Json)[0].name
$release = (Invoke-WebRequest "https://api.github.com/repos/OpenAcousticDevices/AudioMoth-Configuration-App/releases/latest" | ConvertFrom-Json)[0].body

# write new version and release
$file = "./audiomoth-config/audiomoth-config.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

# download installer and LICENSE
Invoke-WebRequest -Uri "https://github.com/OpenAcousticDevices/AudioMoth-Configuration-App/releases/download/$tag/AudioMothConfigurationAppSetup$tag.exe" -OutFile "./audiomoth-config/tools/AudioMothConfigurationAppSetup.exe"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/OpenAcousticDevices/AudioMoth-Configuration-App/master/LICENSE" -OutFile "./audiomoth-config/legal/LICENSE.txt"

# calculation of checksum
$TABLE = Get-FileHash "./audiomoth-config/tools/AudioMothConfigurationAppSetup.exe" -Algorithm SHA256
$SHA = $TABLE.Hash

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official github repository listed on <https://github.com/OpenAcousticDevices/AudioMoth-Configuration-App/releases/>
and can be verified like this:

1. Download the following installer:
  Version $tag : <https://github.com/OpenAcousticDevices/AudioMoth-Configuration-App/releases/download/$tag/AudioMothConfigurationAppSetup$tag.exe>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum: $SHA

File 'LICENSE.txt' is obtained from <https://raw.githubusercontent.com/OpenAcousticDevices/AudioMoth-Configuration-App/master/LICENSE> " | out-file -filepath ./audiomoth-config/legal/VERIFICATION.txt

# packaging
choco pack ./audiomoth-config/audiomoth-config.nuspec --outputdirectory .\audiomoth-config

If ($LastExitCode -eq 0) {
	choco push ./audiomoth-config/audiomoth-config.$tag.nupkg --source https://push.chocolatey.org/
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}

If ($LastExitCode -eq 0) {

# git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - audiomoth-config" --allow-empty
git tag -a audiomoth-config-v$tag -m "Audiomoth Config - version $tag"
git push -f && git push --tags

# create release
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

# post tweet
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

# send telegram notification
Function Send-Telegram {
Param([Parameter(Mandatory=$true)][String]$Message)
$Telegramtoken = "$env:TELEGRAM"
$Telegramchatid = "$env:CHAT_ID"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($Telegramtoken)/sendMessage?chat_id=$($Telegramchatid)&text=$($Message)"}

Send-Telegram -Message "[UCP] New update of Audiomoth-Config-App : $tag"

} else {
	echo "Error in choco push - Exit code: $LastExitCode "
}
