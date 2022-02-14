$tag = (Invoke-WebRequest "https://api.github.com/repos/jely2002/youtube-dl-gui/releases/latest" | ConvertFrom-Json)[0].name
$release = (Invoke-WebRequest "https://api.github.com/repos/jely2002/youtube-dl-gui/releases/latest" | ConvertFrom-Json)[0].body
$tag = $tag -replace 'v'

$regex = '([0-9]{3,})'
$release = $release -replace $regex, '[${1}](https://github.com/jely2002/youtube-dl-gui/issues/${1})'

$file = "./open-video-downloader/open-video-downloader.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://github.com/jely2002/youtube-dl-gui/releases/download/v$tag/Open-Video-Downloader-Setup-$tag.exe" -OutFile "./open-video-downloader/tools/open-video-downloader.exe"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/jely2002/youtube-dl-gui/master/LICENSE" -OutFile "./open-video-downloader/legal/LICENCE.txt"

choco pack ./open-video-downloader/open-video-downloader.nuspec --outputdirectory .\open-video-downloader

If ($LastExitCode -eq 0) {
	choco push ./open-video-downloader/open-video-downloader.$tag.nupkg --source https://push.chocolatey.org/
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}

If ($LastExitCode -eq 0) {

#git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - open-video-downloader" --allow-empty
git tag -a open-video-downloader-v$tag -m "Open Video Downloader - version $tag"
git push -f && git push --tags

#create release
Install-Module -Name New-GitHubRelease -Force
Import-Module -Name New-GitHubRelease
$newGitHubReleaseParameters = @{
GitHubUsername = "A-d-r-i"
GitHubRepositoryName = "update_choco_package"
GitHubAccessToken = "$env:ACTIONS_TOKEN"
ReleaseName = "Open Video Downloader v$tag"
TagName = "open-video-downloader-v$tag"
ReleaseNotes = "$release"
AssetFilePaths = ".\open-video-downloader\open-video-downloader.$tag.nupkg"
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
Send-TwitterStatuses_Update -status "Open Video Downloader v$tag push now on @chocolateynuget! 

Link: https://community.chocolatey.org/packages/open-video-downloader/$tag
@jelleglebbeek
#openvideodownloader #youtubedl #youtubedlgui #release #opensource
"
}

#send telegram notification
Function Send-Telegram {
Param([Parameter(Mandatory=$true)][String]$Message)
$Telegramtoken = "$env:TELEGRAM"
$Telegramchatid = "$env:CHAT_ID"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($Telegramtoken)/sendMessage?chat_id=$($Telegramchatid)&text=$($Message)"}

Send-Telegram -Message "[UCP] New update of Open Video Downloader : $tag"

} else {
	echo "Error in choco push - Exit code: $LastExitCode "
}
