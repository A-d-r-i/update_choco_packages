#$tag = (Invoke-WebRequest "https://api.github.com/repos/firedm/FireDM/releases/latest" | ConvertFrom-Json)[0].tag_name
$tag = '2021.9.28'
$release = (Invoke-WebRequest "https://api.github.com/repos/firedm/FireDM/releases/latest" | ConvertFrom-Json)[0].body

$file = "./firedm/firedm.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://github.com/firedm/FireDM/releases/download/$tag/FireDM_$tag.zip" -OutFile "firedm.zip"
$TABLE = Get-FileHash firedm.zip -Algorithm SHA256
$SHA = $TABLE.Hash

$content = "`$ErrorActionPreference = 'Stop';
`$toolsDir   = `"`$(Split-Path -parent `$MyInvocation.MyCommand.Definition)`"
`$packageName = 'firedm'
`$checksum = '$SHA'
`$checkumType = 'sha256'

Install-ChocolateyZipPackage -PackageName `$packageName -checksum `$checksum -checksumType `$checkumType -Url 'https://github.com/firedm/FireDM/releases/download/$tag/FireDM_$tag.zip' -UnzipLocation `$toolsDir

Install-ChocolateyShortcut -ShortcutFilePath `"`$(`$env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\FireDM.lnk`" -TargetPath `"`$toolsDir\FireDM\firedm.exe`"
Install-ChocolateyShortcut -ShortcutFilePath `"`$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))\FireDM.lnk`" -TargetPath `"`$toolsDir\FireDM\firedm.exe`" " | out-file -filepath ./firedm/tools/chocolateyinstall.ps1

Remove-Item firedm.zip

choco pack ./firedm/firedm.nuspec --outputdirectory .\firedm

If ($LastExitCode -eq 0) {
	choco push ./firedm/firedm.$tag.nupkg --source https://push.chocolatey.org/
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}

If ($LastExitCode -eq 0) {

#git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - firedm" --allow-empty
git tag -a firedm-v$tag -m "FireDM  - version $tag"
git push -f && git push --tags

#create release
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
Send-TwitterStatuses_Update -status "FireDM v$tag push now on @chocolateynuget! 

Link: https://community.chocolatey.org/packages/firedm/$tag
#firedm #release #opensource
"
}
} else {
	echo "Error in choco push - Exit code: $LastExitCode "
}
