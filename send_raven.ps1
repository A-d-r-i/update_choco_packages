$tag = (Invoke-WebRequest "https://api.github.com/repos/hello-efficiency-inc/raven-reader/releases/latest" | ConvertFrom-Json)[0].name
$tag = $tag -replace 'v'
$release = (Invoke-WebRequest "https://api.github.com/repos/hello-efficiency-inc/raven-reader/releases/latest" | ConvertFrom-Json)[0].body

# $regex = '([0-9]{3,})'
# $release = $release -replace $regex, '[${1}](https://github.com/hello-efficiency-inc/raven-reader/issues/${1})'

$file = "./raven/raven.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://github.com/hello-efficiency-inc/raven-reader/releases/download/v$tag/Raven-Reader-Setup-$tag.exe" -OutFile "raven.exe"

$TABLE = Get-FileHash raven.exe -Algorithm SHA256
$SHA = $TABLE.Hash

$content = "`$packageName = 'raven'
`$installerType = 'EXE'
`$url = 'https://github.com/hello-efficiency-inc/raven-reader/releases/download/v$tag/Raven-Reader-Setup-$tag.exe'
`$checksum = '$SHA'
`$checkumType = 'sha256'
`$silentArgs = '/S'
`$validExitCodes = @(0)
Install-ChocolateyPackage `"`$packageName`" `"`$installerType`" `"`$silentArgs`" `"`$url`" -checksum `$checksum -checksumType `$checkumType -validExitCodes `$validExitCodes " | out-file -filepath ./raven/tools/chocolateyinstall.ps1

Remove-Item raven.exe

choco pack ./raven/raven.nuspec --outputdirectory .\raven


If ($LastExitCode -eq 0) {
	choco push ./raven/raven.$tag.nupkg --source https://push.chocolatey.org/
} else {
 'Error - Exit code: $LastExitCode'
}

#git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - Raven" --allow-empty
git tag -a raven-v$tag -m "Raven Reader - version $tag"
git push -f && git push --tags

#create release
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
Send-TwitterStatuses_Update -status "Raven Reader v$tag push now on @chocolateynuget! 

Link: https://community.chocolatey.org/packages/raven/$tag
@helloefficiency @mrgodhani
#raven #release #opensource
"
}
