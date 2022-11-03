# extract latest version and release
Invoke-WebRequest -Uri "https://www.mendeley.com/release-notes-reference-manager/" -OutFile "MRM.html"
$Source = Get-Content -path MRM.html -raw
$Source -match 'https://static.mendeley.com/md-stitch/releases/live/release-notes-reference-manager.([a-z\d]*).js'
$Sourceurl = $matches[1]

Invoke-WebRequest -Uri "https://static.mendeley.com/md-stitch/releases/live/release-notes-reference-manager.$Sourceurl.js" -OutFile "MRM.txt"
$Source = Get-Content -path MRM.txt -raw
$Source -match 'page:new URL\([a-z]\),path:"/v([0-9]+(\.[0-9]+)+)"'
$tag = $matches[1]

# release notes
$Sourcerelease = Get-Content -path MRM.txt -raw
$Sourcerelease -match 'path:"/v([0-9]+(\.[0-9]+)+)"'
$path = $matches[1]
$Sourcerelease -match "([0-9]+)_v$path.([a-zA-Z0-9]+).html"
$daterelease = $matches[1]
$daterelease = -join($daterelease, "_v");
$idrelease = $matches[2]
$URLrelease = "https://static.mendeley.com/md-stitch/releases/live/$daterelease$path.$idrelease.html"

Install-Module -Name MarkdownPrince -Force
Invoke-WebRequest -Uri "$URLrelease" -OutFile "MRM.html"
ConvertFrom-HTMLToMarkdown -Path "MRM.html" -UnknownTags Drop -GithubFlavored -DestinationPath "MRM.md"
$release = Get-Content -path MRM.md -raw
$release = -join($release, "`n`n**Full changelog:** [https://www.mendeley.com/release-notes-reference-manager/v$tag](https://www.mendeley.com/release-notes-reference-manager/v$path) ");

# write new version and release
$file = "./mendeley-reference-manager/mendeley-reference-manager.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

# download installer
Invoke-WebRequest -Uri "https://static.mendeley.com/bin/desktop/mendeley-reference-manager-$tag.exe" -OutFile "./mendeley-reference-manager/tools/mendeley-reference-manager.exe"

Remove-Item MRM.txt
Remove-Item MRM.html
Remove-Item MRM.md

# calculation of checksum
$TABLE = Get-FileHash "./mendeley-reference-manager/tools/mendeley-reference-manager.exe" -Algorithm SHA256
$SHA = $TABLE.Hash

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official site repository listed on <https://www.mendeley.com/release-notes-reference-manager/>
and can be verified like this:

1. Download the following installer:
  Version $tag : <https://static.mendeley.com/bin/desktop/mendeley-reference-manager-$tag.exe>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum: $SHA

File 'LICENSE.txt' is obtained from the official website " | out-file -filepath ./mendeley-reference-manager/legal/VERIFICATION.txt

# packaging
choco pack ./mendeley-reference-manager/mendeley-reference-manager.nuspec --outputdirectory .\mendeley-reference-manager

If ($LastExitCode -eq 0) {
	choco push ./mendeley-reference-manager/mendeley-reference-manager.$tag.nupkg --source https://push.chocolatey.org/
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}

If ($LastExitCode -eq 0) {

# git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - Mendeley - RM" --allow-empty
git tag -a mendeley-rm-v$tag -m "Mendeley-Reference-Manager - version $tag"
git push -f && git push --tags

# create release
Install-Module -Name New-GitHubRelease -Force
Import-Module -Name New-GitHubRelease
$newGitHubReleaseParameters = @{
GitHubUsername = "A-d-r-i"
GitHubRepositoryName = "update_choco_package"
GitHubAccessToken = "$env:ACTIONS_TOKEN"
ReleaseName = "Mendeley-Reference-Manager v$tag"
TagName = "mendeley-rm-v$tag"
ReleaseNotes = "$release"
AssetFilePaths = ".\mendeley-reference-manager\mendeley-reference-manager.$tag.nupkg"
IsPreRelease = $false
IsDraft = $false
}
$resultrelease = New-GitHubRelease @newGitHubReleaseParameters

# post tweet
Invoke-WebRequest -Uri "https://adrisupport.000webhostapp.com/UCP/index.php" -OutFile "UCP.html"
$Source = Get-Content -path UCP.html -raw
$Source -match '<td>twitter</td><td>(.*?)</td>'
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
Send-TwitterStatuses_Update -status "Mendeley-Reference-Manager v$tag push now on @chocolateynuget! 
Link: https://community.chocolatey.org/packages/mendeley-reference-manager/$tag
@mendeley_com @MendeleyApp @MendeleyTips
#mendeley #release #opensource
"
}

# send telegram notification
Function Send-Telegram {
Param([Parameter(Mandatory=$true)][String]$Message)
$Telegramtoken = "$env:TELEGRAM"
$Telegramchatid = "$env:CHAT_ID"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($Telegramtoken)/sendMessage?chat_id=$($Telegramchatid)&text=$($Message)"}

Send-Telegram -Message "[UCP] New update of Mendeley-Reference-Manager : $tag"

} else {
	echo "Error in choco push - Exit code: $LastExitCode "
}
