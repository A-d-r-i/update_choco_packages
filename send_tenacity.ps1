# $tag = (Invoke-WebRequest "https://api.github.com/repos/tenacityteam/tenacity/releases/latest" | ConvertFrom-Json)[0].name
# $release = (Invoke-WebRequest "https://api.github.com/repos/tenacityteam/tenacity/releases/latest" | ConvertFrom-Json)[0].body
Invoke-WebRequest -Uri "https://nightly.link/tenacityteam/tenacity/workflows/cmake_build/master" -OutFile "tenacity.html"
$Source = Get-Content -path tenacity.html -raw
$Source -match 'Tenacity_windows-server-2019-amd64-x64_windows-ninja(_[0-9]+_)'
$run = $matches[1]

$tag = "0.1.0.001-alpha"

$file = "./tenacity/tenacity.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
# $xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://nightly.link/tenacityteam/tenacity/workflows/cmake_build/master/Tenacity_windows-server-2019-amd64-x64_windows-ninja$run.zip" -OutFile "tenacity64.zip"
Invoke-WebRequest -Uri "https://nightly.link/tenacityteam/tenacity/workflows/cmake_build/master/Tenacity_windows-server-2019-x86-x86_windows-ninja$run.zip" -OutFile "tenacity32.zip"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tenacityteam/tenacity/master/LICENSE.txt" -OutFile "./tenacity/legal/LICENSE.txt"

Expand-Archive tenacity64.zip -DestinationPath .\tenacity\tools\ -Force
Expand-Archive tenacity32.zip -DestinationPath .\tenacity\tools\ -Force
Rename-Item -Path ".\tenacity\tools\tenacity-win-3.0.4-x64.exe" -NewName "tenacity64.exe"
Rename-Item -Path ".\tenacity\tools\tenacity-win-3.0.4-x86.exe" -NewName "tenacity32.exe"

$content = "`$ErrorActionPreference = 'Stop'
`$toolsDir = Split-Path `$MyInvocation.MyCommand.Definition
`$packageArgs = @{
  packageName    = 'tenacity'
  fileType       = 'exe'
  file           = `"`$toolsDir\tenacity32.exe`"
  file64         = `"`$toolsDir\tenacity64.exe`"
  silentArgs     = '/VERYSILENT'
  validExitCodes = @(0, 1223)
}
Install-ChocolateyInstallPackage @packageArgs
Get-ChildItem `"`$toolsDir\*.`$(`$packageArgs.fileType)`" | ForEach-Object {
  Remove-Item `$_ -ea 0
  if (Test-Path `$_) {
    Set-Content `"`$_.ignore`"
  }
}
`$packageName = `$packageArgs.packageName
`$installLocation = Get-AppInstallLocation `$packageName
if (`$installLocation) {
  Write-Host `"`$packageName installed to '`$installLocation'`"
  Register-Application `"`$installLocation\`$packageName.exe`"
  Write-Host `"`$packageName registered as `$packageName`"
}
else { Write-Warning `"Can't find `$PackageName install location`" } " | out-file -filepath ./tenacity/tools/chocolateyinstall.ps1

Remove-Item tenacity64.zip
Remove-Item tenacity32.zip

choco pack ./tenacity/tenacity.nuspec --outputdirectory .\tenacity

If ($LastExitCode -eq 0) {
	choco push ./tenacity/tenacity.$tag.nupkg --source https://push.chocolatey.org/
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}

If ($LastExitCode -eq 0) {

#git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - Tenacity" --allow-empty
git tag -a tenacity-v$tag -m "Tenacity - version $tag"
git push -f && git push --tags

#create release
Install-Module -Name New-GitHubRelease -Force
Import-Module -Name New-GitHubRelease
$newGitHubReleaseParameters = @{
GitHubUsername = "A-d-r-i"
GitHubRepositoryName = "update_choco_package"
GitHubAccessToken = "$env:ACTIONS_TOKEN"
ReleaseName = "Tenacity v$tag"
TagName = "tenacity-v$tag"
ReleaseNotes = "$release"
AssetFilePaths = ".\tenacity\tenacity.$tag.nupkg"
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
Send-TwitterStatuses_Update -status "Tenacity v$tag push now on @chocolateynuget! 

Link: https://community.chocolatey.org/packages/tenacity/$tag
@TenacityAudio
#tenacity #release #opensource
"
}

#send telegram notification
Function Send-Telegram {
Param([Parameter(Mandatory=$true)][String]$Message)
$Telegramtoken = "$env:TELEGRAM"
$Telegramchatid = "$env:CHAT_ID"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($Telegramtoken)/sendMessage?chat_id=$($Telegramchatid)&text=$($Message)"}

Send-Telegram -Message "[UCP] New update of Tenacity : $tag"

} else {
	echo "Error in choco push - Exit code: $LastExitCode "
}
