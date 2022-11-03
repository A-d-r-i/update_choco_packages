# extract latest version and release
$tag = (Invoke-WebRequest "https://api.github.com/repos/CTemplar/webclient/releases/latest" | ConvertFrom-Json)[0].name
$release = (Invoke-WebRequest "https://api.github.com/repos/CTemplar/webclient/releases/latest" | ConvertFrom-Json)[0].body

# write new version and release
$file = "./ctemplar/ctemplar.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

# download installer and LICENSE
Invoke-WebRequest -Uri "https://github.com/CTemplar/webclient/releases/download/v$tag/CTemplar-$tag.exe" -OutFile "./ctemplar/tools/ctemplar.exe"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/CTemplar/webclient/master/LICENCE" -OutFile "./ctemplar/legal/LICENSE.txt"

# calculation of checksum
$TABLE = Get-FileHash "./ctemplar/tools/ctemplar.exe" -Algorithm SHA256
$SHA = $TABLE.Hash

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official github repository listed on <https://github.com/CTemplar/webclient/releases/>
and can be verified like this:

1. Download the following installer:
  Version $tag : <https://github.com/CTemplar/webclient/releases/download/v$tag/CTemplar-$tag.exe>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum: $SHA

File 'LICENSE.txt' is obtained from <https://raw.githubusercontent.com/CTemplar/webclient/master/LICENCE> " | out-file -filepath ./ctemplar/legal/VERIFICATION.txt

# packaging
choco pack ./ctemplar/ctemplar.nuspec --outputdirectory .\ctemplar

If ($LastExitCode -eq 0) {
	choco push ./ctemplar/ctemplar.$tag.nupkg --source https://push.chocolatey.org/
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}

If ($LastExitCode -eq 0) {
# git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - ctemplar" --allow-empty
git tag -a ctemplar-v$tag -m "CTemplar - version $tag"
git push -f && git push --tags

# create release
Install-Module -Name New-GitHubRelease -Force
Import-Module -Name New-GitHubRelease
$newGitHubReleaseParameters = @{
GitHubUsername = "A-d-r-i"
GitHubRepositoryName = "update_choco_package"
GitHubAccessToken = "$env:ACTIONS_TOKEN"
ReleaseName = "CTemplar v$tag"
TagName = "ctemplar-v$tag"
ReleaseNotes = "$release"
AssetFilePaths = ".\ctemplar\ctemplar.$tag.nupkg"
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
Send-TwitterStatuses_Update -status "CTemplar v$tag push now on @chocolateynuget! 

Link: https://community.chocolatey.org/packages/ctemplar/$tag
@RealCTemplar
#ctemplar #release #opensource
"
}

# send telegram notification
Function Send-Telegram {
Param([Parameter(Mandatory=$true)][String]$Message)
$Telegramtoken = "$env:TELEGRAM"
$Telegramchatid = "$env:CHAT_ID"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($Telegramtoken)/sendMessage?chat_id=$($Telegramchatid)&text=$($Message)"}

Send-Telegram -Message "[UCP] New update of CTemplar : $tag"

} else {
	echo "Error in choco push - Exit code: $LastExitCode "
}
