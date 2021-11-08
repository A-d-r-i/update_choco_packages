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

$file = "./fluffychat/fluffychat.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://gitlab.com/api/v4/projects/16112282/packages/generic/fluffychat/$tag/fluffychat-windows.zip" -OutFile "fluffychat.zip"
$TABLE = Get-FileHash fluffychat.zip -Algorithm SHA256
$SHA = $TABLE.Hash

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

choco pack ./fluffychat/fluffychat.nuspec --outputdirectory .\fluffychat

If ($LastExitCode -eq 0) {
	choco push ./fluffychat/fluffychat.$tag.nupkg --source https://push.chocolatey.org/
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}

If ($LastExitCode -eq 0) {

#git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - fluffychat" --allow-empty
git tag -a fluffychat-v$tag -m "FluffyChat  - version $tag"
git push -f && git push --tags

#create release
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
Send-TwitterStatuses_Update -status "FluffyChat v$tag push now on @chocolateynuget! 

Link: https://community.chocolatey.org/packages/fluffychat/$tag
#fluffychat #release #opensource
"
}
} else {
	echo "Error in choco push - Exit code: $LastExitCode "
}
