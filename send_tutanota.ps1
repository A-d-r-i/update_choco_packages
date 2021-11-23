$tag = (Invoke-WebRequest "https://api.github.com/repos/tutao/tutanota/releases/latest" | ConvertFrom-Json)[0].name
$release = (Invoke-WebRequest "https://api.github.com/repos/tutao/tutanota/releases/latest" | ConvertFrom-Json)[0].body

$regex = '([0-9]{4,})'
$release = $release -replace $regex, '[${1}](https://github.com/tutao/tutanota/issues/${1})'

$file = "./tutanota/tutanota.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://mail.tutanota.com/desktop/tutanota-desktop-win.exe" -OutFile "./tutanota/tools/tutanota-desktop-win.exe"

choco pack ./tutanota/tutanota.nuspec --outputdirectory .\tutanota

If ($LastExitCode -eq 0) {
	choco push ./tutanota/tutanota.$tag.nupkg --source https://push.chocolatey.org/
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}

If ($LastExitCode -eq 0) {

#git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - Tutanota" --allow-empty
git tag -a tutanota-v$tag -m "Tutanota - version $tag"
git push -f && git push --tags

#create release
Install-Module -Name New-GitHubRelease -Force
Import-Module -Name New-GitHubRelease
$newGitHubReleaseParameters = @{
GitHubUsername = "A-d-r-i"
GitHubRepositoryName = "update_choco_package"
GitHubAccessToken = "$env:ACTIONS_TOKEN"
ReleaseName = "Tutanota v$tag"
TagName = "tutanota-v$tag"
ReleaseNotes = "$release"
AssetFilePaths = ".\tutanota\tutanota.$tag.nupkg"
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
Send-TwitterStatuses_Update -status "Tutanota v$tag push now on @chocolateynuget! 

Link: https://community.chocolatey.org/packages/tutanota/$tag
@TutanotaTeam
#tutanota #release #opensource
"
}

#send telegram notification
Function Send-Telegram {
Param([Parameter(Mandatory=$true)][String]$Message)
$Telegramtoken = "$env:TELEGRAM"
$Telegramchatid = "$env:CHAT_ID"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($Telegramtoken)/sendMessage?chat_id=$($Telegramchatid)&text=$($Message)"}

Send-Telegram -Message "[UCP] New update of Tutanota : $tag"

} else {
	echo "Error in choco push - Exit code: $LastExitCode "
}
