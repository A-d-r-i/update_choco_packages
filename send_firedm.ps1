# extract latest version and release
$tag = (Invoke-WebRequest "https://api.github.com/repos/firedm/FireDM/releases/latest" | ConvertFrom-Json)[0].tag_name
$release = (Invoke-WebRequest "https://api.github.com/repos/firedm/FireDM/releases/latest" | ConvertFrom-Json)[0].body

$regex = '#([0-9]{3,})'
$release = $release -replace $regex, '[#${1}](https://github.com/firedm/FireDM/issues/${1})'

# write new version and release
$file = "./firedm/firedm.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

# download installer and LICENSE
Invoke-WebRequest -Uri "https://github.com/firedm/FireDM/releases/download/$tag/FireDM_$tag.zip" -OutFile "firedm.zip"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/firedm/FireDM/master/LICENSE" -OutFile "./firedm/legal/LICENSE.txt"

# calculation of checksum
$TABLE = Get-FileHash firedm.zip -Algorithm SHA256
$SHA = $TABLE.Hash

# writing of chocolateyinstall.ps1
$content = "`$ErrorActionPreference = 'Stop';
`$toolsDir   = `"`$(Split-Path -parent `$MyInvocation.MyCommand.Definition)`"

`$packageArgs = @{
  packageName   = 'firedm'
  checksum = '$SHA'
  checksumType = 'sha256'
  Url = 'https://github.com/firedm/FireDM/releases/download/$tag/FireDM_$tag.zip'
  UnzipLocation = `$toolsDir
}

Install-ChocolateyZipPackage @packageArgs

Install-ChocolateyShortcut -ShortcutFilePath `"`$(`$env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\FireDM.lnk`" -TargetPath `"`$toolsDir\FireDM\firedm.exe`"
Install-ChocolateyShortcut -ShortcutFilePath `"`$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))\FireDM.lnk`" -TargetPath `"`$toolsDir\FireDM\firedm.exe`" " | out-file -filepath ./firedm/tools/chocolateyinstall.ps1

Remove-Item firedm.zip

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official github repository listed on <https://github.com/firedm/FireDM/releases/>
and can be verified like this:

1. Download the following installer:
  Version $tag : <https://github.com/firedm/FireDM/releases/download/$tag/FireDM_$tag.zip>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum: $SHA

File 'LICENSE.txt' is obtained from <https://raw.githubusercontent.com/firedm/FireDM/master/LICENSE> " | out-file -filepath ./firedm/legal/VERIFICATION.txt

# packaging
choco pack ./firedm/firedm.nuspec --outputdirectory .\firedm

If ($LastExitCode -eq 0) {
	choco push ./firedm/firedm.$tag.nupkg --source https://push.chocolatey.org/
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}

If ($LastExitCode -eq 0) {

# git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - firedm" --allow-empty
git tag -a firedm-v$tag -m "FireDM  - version $tag"
git push -f && git push --tags

# create release
Install-Module -Name New-GitHubRelease -Force
Import-Module -Name New-GitHubRelease
$newGitHubReleaseParameters = @{
GitHubUsername = "A-d-r-i"
GitHubRepositoryName = "update_choco_package"
GitHubAccessToken = "$env:ACTIONS_TOKEN"
ReleaseName = "FireDM v$tag"
TagName = "firedm-v$tag"
ReleaseNotes = "$release"
AssetFilePaths = ".\firedm\firedm.$tag.nupkg"
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
Send-TwitterStatuses_Update -status "FireDM v$tag push now on @chocolateynuget! 

Link: https://community.chocolatey.org/packages/firedm/$tag
#firedm #release #opensource
"
}

# send telegram notification
Function Send-Telegram {
Param([Parameter(Mandatory=$true)][String]$Message)
$Telegramtoken = "$env:TELEGRAM"
$Telegramchatid = "$env:CHAT_ID"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($Telegramtoken)/sendMessage?chat_id=$($Telegramchatid)&text=$($Message)"}

Send-Telegram -Message "[UCP] New update of FireDM : $tag"

} else {
	echo "Error in choco push - Exit code: $LastExitCode "
}
