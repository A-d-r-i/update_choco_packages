# variables
$id = "homebank"
$name = "HomeBank"
$accounts = ""
$tags = "#homebank"

# extract latest version and release
$tag = (Invoke-WebRequest "https://api.github.com/repos/streetwriters/notesnook/releases/latest" | ConvertFrom-Json)[0].tag_name
$tag = $tag -replace 'v'
$release = (Invoke-WebRequest "https://api.github.com/repos/streetwriters/notesnook/releases/latest" | ConvertFrom-Json)[0].body

# write new version and release
$file = "./notesnook/notesnook.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

# download installer and LICENSE
Invoke-WebRequest -Uri "https://github.com/streetwriters/notesnook/releases/download/v$tag/notesnook_win_x64.exe" -OutFile "./notesnook/tools/notesnook.exe"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/streetwriters/notesnook/master/LICENSE" -OutFile "./notesnook/legal/LICENSE.txt"

# calculation of checksum
$TABLE = Get-FileHash "./notesnook/tools/notesnook.exe" -Algorithm SHA256
$SHA = $TABLE.Hash

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official github repository listed on <https://github.com/streetwriters/notesnook/releases/>
and can be verified like this:

1. Download the following installer:
  Version $tag : <https://github.com/streetwriters/notesnook/releases/download/v$tag/notesnook_win_x64.exe>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum: $SHA

File 'LICENSE.txt' is obtained from <https://raw.githubusercontent.com/streetwriters/notesnook/master/LICENSE> " | out-file -filepath ./notesnook/legal/VERIFICATION.txt

# packaging
choco pack ./notesnook/notesnook.nuspec --outputdirectory .\notesnook

If ($LastExitCode -eq 0) {
	choco push ./notesnook/notesnook.$tag.nupkg --source https://push.chocolatey.org/
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}

If ($LastExitCode -eq 0) {

# git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - notesnook" --allow-empty
git tag -a notesnook-v$tag -m "Notesnook - version $tag"
git push -f && git push --tags

# create release
Install-Module -Name New-GitHubRelease -Force
Import-Module -Name New-GitHubRelease
$newGitHubReleaseParameters = @{
GitHubUsername = "A-d-r-i"
GitHubRepositoryName = "update_choco_package"
GitHubAccessToken = "$env:ACTIONS_TOKEN"
ReleaseName = "Notesnook v$tag"
TagName = "notesnook-v$tag"
ReleaseNotes = "$release"
AssetFilePaths = ".\notesnook\notesnook.$tag.nupkg"
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
Send-TwitterStatuses_Update -status "Notesnook v$tag push now on @chocolateynuget! 

Link: https://community.chocolatey.org/packages/notesnook/$tag
@notesnook
#notesnook #release #opensource
"
}

# send telegram notification
Function Send-Telegram {
Param([Parameter(Mandatory=$true)][String]$Message)
$Telegramtoken = "$env:TELEGRAM"
$Telegramchatid = "$env:CHAT_ID"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($Telegramtoken)/sendMessage?chat_id=$($Telegramchatid)&text=$($Message)"}

Send-Telegram -Message "[UCP] New update of Notesnook : $tag"

} else {
	echo "Error in choco push - Exit code: $LastExitCode "
}
