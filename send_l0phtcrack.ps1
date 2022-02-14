$tag = (Invoke-WebRequest "https://gitlab.com/api/v4/projects/28508791/releases" | ConvertFrom-Json)[0].tag_name
$release = (Invoke-WebRequest "https://gitlab.com/api/v4/projects/28508791/releases" | ConvertFrom-Json)[0].description

$file = "./l0phtcrack/l0phtcrack.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

$tag32 = -join($tag,"_Win32");
$tag64 = -join($tag,"_Win64");

Invoke-WebRequest -Uri "https://l0phtcrack.gitlab.io/releases/$tag/lc7setup_v$tag32.exe" -OutFile "l0phtcrack32.exe"
Invoke-WebRequest -Uri "https://l0phtcrack.gitlab.io/releases/$tag/lc7setup_v$tag64.exe" -OutFile "l0phtcrack64.exe"
Invoke-WebRequest -Uri "https://gitlab.com/l0phtcrack/l0phtcrack/-/raw/main/LICENSE.MIT" -OutFile "./l0phtcrack/legal/LICENSE.txt"

$TABLE64 = Get-FileHash l0phtcrack64.exe -Algorithm SHA256
$SHA64 = $TABLE64.Hash

$TABLE32 = Get-FileHash l0phtcrack32.exe -Algorithm SHA256
$SHA32 = $TABLE32.Hash

$content = "`$ErrorActionPreference = 'Stop';

`$packageArgs = @{
  packageName = 'l0phtcrack'
  installerType = 'EXE'
  url = 'https://l0phtcrack.gitlab.io/releases/$tag/lc7setup_v$tag32.exe'
  checksum = '$SHA32'
  url64 = 'https://l0phtcrack.gitlab.io/releases/$tag/lc7setup_v$tag64.exe'
  checksum64 = '$SHA64'
  checkumType = 'sha256'
  silentArgs = '/S'
  validExitCodes = @(0)
}

Install-ChocolateyInstallPackage @packageArgs " | out-file -filepath ./l0phtcrack/tools/chocolateyinstall.ps1

Remove-Item l0phtcrack64.exe
Remove-Item l0phtcrack32.exe

choco pack ./l0phtcrack/l0phtcrack.nuspec --outputdirectory .\l0phtcrack

If ($LastExitCode -eq 0) {
	choco push ./l0phtcrack/l0phtcrack.$tag.nupkg --source https://push.chocolatey.org/
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}

If ($LastExitCode -eq 0) {
#git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - l0phtcrack" --allow-empty
git tag -a l0phtcrack-v$tag -m "L0phtCrack - version $tag"
git push -f && git push --tags

#create release
Install-Module -Name New-GitHubRelease -Force
Import-Module -Name New-GitHubRelease
$newGitHubReleaseParameters = @{
GitHubUsername = "A-d-r-i"
GitHubRepositoryName = "update_choco_package"
GitHubAccessToken = "$env:ACTIONS_TOKEN"
ReleaseName = "L0phtCrack v$tag"
TagName = "l0phtcrack-v$tag"
ReleaseNotes = "$release"
AssetFilePaths = ".\l0phtcrack\l0phtcrack.$tag.nupkg"
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
Send-TwitterStatuses_Update -status "L0phtCrack v$tag push now on @chocolateynuget! 

Link: https://community.chocolatey.org/packages/l0phtcrack/$tag
@L0phtCrackLLC
#ctemplar #release #opensource
"
}

#send telegram notification
Function Send-Telegram {
Param([Parameter(Mandatory=$true)][String]$Message)
$Telegramtoken = "$env:TELEGRAM"
$Telegramchatid = "$env:CHAT_ID"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($Telegramtoken)/sendMessage?chat_id=$($Telegramchatid)&text=$($Message)"}

Send-Telegram -Message "[UCP] New update of L0phtCrack : $tag"

} else {
	echo "Error in choco push - Exit code: $LastExitCode "
}
