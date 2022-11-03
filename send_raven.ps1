# extract latest version and release
$tag = (Invoke-WebRequest "https://api.github.com/repos/hello-efficiency-inc/raven-reader/releases/latest" | ConvertFrom-Json)[0].name
$tag = $tag -replace 'v'
$release = (Invoke-WebRequest "https://api.github.com/repos/hello-efficiency-inc/raven-reader/releases/latest" | ConvertFrom-Json)[0].body

# $regex = '([0-9]{3,})'
# $release = $release -replace $regex, '[${1}](https://github.com/hello-efficiency-inc/raven-reader/issues/${1})'

# write new version and release
$file = "./raven/raven.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

# download installer and LICENSE
Invoke-WebRequest -Uri "https://github.com/hello-efficiency-inc/raven-reader/releases/download/v$tag/Raven-Reader-Setup-$tag.exe" -OutFile "./raven/tools/raven.exe"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/hello-efficiency-inc/raven-reader/master/LICENSE" -OutFile "./raven/legal/LICENSE.txt"

# calculation of checksum
$TABLE = Get-FileHash "./raven/tools/raven.exe" -Algorithm SHA256
$SHA = $TABLE.Hash

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official github repository listed on <https://github.com/hello-efficiency-inc/raven-reader/releases/>
and can be verified like this:

1. Download the following installer:
  Version $tag : <https://github.com/hello-efficiency-inc/raven-reader/releases/download/v$tag/Raven-Reader-Setup-$tag.exe>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum: $SHA

File 'LICENSE.txt' is obtained from <https://raw.githubusercontent.com/hello-efficiency-inc/raven-reader/master/LICENSE> " | out-file -filepath ./raven/legal/VERIFICATION.txt

# packaging
choco pack ./raven/raven.nuspec --outputdirectory .\raven


If ($LastExitCode -eq 0) {
	choco push ./raven/raven.$tag.nupkg --source https://push.chocolatey.org/
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}

If ($LastExitCode -eq 0) {

# git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - Raven" --allow-empty
git tag -a raven-v$tag -m "Raven Reader - version $tag"
git push -f && git push --tags

# create release
Install-Module -Name New-GitHubRelease -Force
Import-Module -Name New-GitHubRelease
$newGitHubReleaseParameters = @{
GitHubUsername = "A-d-r-i"
GitHubRepositoryName = "update_choco_package"
GitHubAccessToken = "$env:ACTIONS_TOKEN"
ReleaseName = "Raven Reader v$tag"
TagName = "raven-v$tag"
ReleaseNotes = "$release"
AssetFilePaths = ".\raven\raven.$tag.nupkg"
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
Send-TwitterStatuses_Update -status "Raven Reader v$tag push now on @chocolateynuget! 

Link: https://community.chocolatey.org/packages/raven/$tag
@helloefficiency @mrgodhani
#raven #release #opensource
"
}

# send telegram notification
Function Send-Telegram {
Param([Parameter(Mandatory=$true)][String]$Message)
$Telegramtoken = "$env:TELEGRAM"
$Telegramchatid = "$env:CHAT_ID"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($Telegramtoken)/sendMessage?chat_id=$($Telegramchatid)&text=$($Message)"}

Send-Telegram -Message "[UCP] New update of Raven Reader : $tag"

} else {
	echo "Error in choco push - Exit code: $LastExitCode "
}
