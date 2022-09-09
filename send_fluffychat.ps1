# extract latest version and release
$tag = (Invoke-WebRequest "https://gitlab.com/api/v4/projects/16112282/releases" | ConvertFrom-Json)[0].tag_name
$tag = $tag -replace 'v'

Invoke-WebRequest -Uri "https://gitlab.com/famedly/fluffychat/-/raw/main/CHANGELOG.md" -OutFile "FC.md"
$text = Get-Content -path FC.md
$pattern = '##(.*?)##'
$result = [regex]::match($text, $pattern).Groups[1].Value
$release = $result -replace '^','##'
$release = $release -replace "(- [0-9]{4}-[0-9]{2}-[0-9]{2} )","$&`n"
$release = $release -replace "- [a-zA-Z]","`n $&"
$release = -join($release, "`n`n**Full changelog:** [https://gitlab.com/famedly/fluffychat/-/blob/main/CHANGELOG.md](https://gitlab.com/famedly/fluffychat/-/blob/main/CHANGELOG.md) ");

# write new version and release
$file = "./fluffychat/fluffychat.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

# download installer and LICENSE
Invoke-WebRequest -Uri "https://gitlab.com/api/v4/projects/16112282/packages/generic/fluffychat/$tag/fluffychat-windows.zip" -OutFile "fluffychat.zip"
Invoke-WebRequest -Uri "https://gitlab.com/famedly/fluffychat/-/raw/main/LICENSE" -OutFile "./fluffychat/legal/LICENSE.txt"

# calculation of checksum
$TABLE = Get-FileHash fluffychat.zip -Algorithm SHA256
$SHA = $TABLE.Hash

# writing of chocolateyinstall.ps1
$content = "`$ErrorActionPreference = 'Stop';
`$toolsDir   = `"`$(Split-Path -parent `$MyInvocation.MyCommand.Definition)`"

`$packageArgs = @{
  packageName   = 'fluffychat'
  checksum = '$SHA'
  checksumType = 'sha256'
  Url = 'https://gitlab.com/api/v4/projects/16112282/packages/generic/fluffychat/$tag/fluffychat-windows.zip'
  UnzipLocation = `$toolsDir
}

Install-ChocolateyZipPackage @packageArgs

Install-ChocolateyShortcut -ShortcutFilePath `"`$(`$env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\FluffyChat.lnk`" -TargetPath `"`$toolsDir\fluffychat.exe`"
Install-ChocolateyShortcut -ShortcutFilePath `"`$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))\FluffyChat.lnk`" -TargetPath `"`$toolsDir\fluffychat.exe`" " | out-file -filepath ./fluffychat/tools/chocolateyinstall.ps1

Remove-Item FC.md
Remove-Item fluffychat.zip

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official gitlab repository listed on <https://gitlab.com/famedly/fluffychat/-/releases>
and can be verified like this:

1. Download the following installer:
  Version $tag : <https://gitlab.com/api/v4/projects/16112282/packages/generic/fluffychat/$tag/fluffychat-windows.zip>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum: $SHA

File 'LICENSE.txt' is obtained from <https://gitlab.com/famedly/fluffychat/-/raw/main/LICENSE> " | out-file -filepath ./fluffychat/legal/VERIFICATION.txt

# packaging
choco pack ./fluffychat/fluffychat.nuspec --outputdirectory .\fluffychat

If ($LastExitCode -eq 0) {
	choco push "./fluffychat/fluffychat.$tag.nupkg" --source https://push.chocolatey.org/
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}

If ($LastExitCode -eq 0) {

# git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - fluffychat" --allow-empty
git tag -a fluffychat-v$tag -m "FluffyChat  - version $tag"
git push -f && git push --tags

# create release
Install-Module -Name New-GitHubRelease -Force
Import-Module -Name New-GitHubRelease
$newGitHubReleaseParameters = @{
GitHubUsername = "A-d-r-i"
GitHubRepositoryName = "update_choco_package"
GitHubAccessToken = "$env:ACTIONS_TOKEN"
ReleaseName = "FluffyChat v$tag"
TagName = "fluffychat-v$tag"
ReleaseNotes = "$release"
AssetFilePaths = ".\fluffychat\fluffychat.$tag.nupkg"
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
Send-TwitterStatuses_Update -status "FluffyChat v$tag push now on @chocolateynuget! 

Link: https://community.chocolatey.org/packages/fluffychat/$tag
#fluffychat #release #opensource
"
}

# send telegram notification
Function Send-Telegram {
Param([Parameter(Mandatory=$true)][String]$Message)
$Telegramtoken = "$env:TELEGRAM"
$Telegramchatid = "$env:CHAT_ID"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($Telegramtoken)/sendMessage?chat_id=$($Telegramchatid)&text=$($Message)"}

Send-Telegram -Message "[UCP] New update of FluffyChat : $tag"

} else {
	echo "Error in choco push - Exit code: $LastExitCode "
}
