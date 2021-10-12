$tag = (Invoke-WebRequest "https://api.github.com/repos/axcore/tartube/releases/latest" | ConvertFrom-Json)[0].tag_name
$tag = $tag -replace 'v'
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/axcore/tartube/master/CHANGES" -OutFile "release.txt"
$text = Get-Content -path release.txt

$pattern = '-------------------------------------------------------------------------------(.*?)v([0-9]+(\.[0-9]+)+)'
$result = [regex]::match($text, $pattern).Groups[1].Value

$release = $result -replace ' - ', "`n- "
$release = $release -replace '     ', ' '
$release = $release -replace '  ', "`n# "
$regex = '([0-9]{3,})'
$release = $release -replace $regex, '[${1}](https://github.com/axcore/tartube/issues/${1})'
$release = -join($release, "`n**Full changelog:** [https://raw.githubusercontent.com/axcore/tartube/master/CHANGES](https://raw.githubusercontent.com/axcore/tartube/master/CHANGES)");

$file = "./tartube/tartube.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://github.com/axcore/tartube/releases/download/v$tag/install-tartube-$tag-64bit.exe" -OutFile "tartube64.exe"
Invoke-WebRequest -Uri "https://github.com/axcore/tartube/releases/download/v$tag/install-tartube-$tag-32bit.exe" -OutFile "tartube32.exe"

$TABLE64 = Get-FileHash tartube64.exe -Algorithm SHA256
$SHA64 = $TABLE64.Hash

$TABLE32 = Get-FileHash tartube32.exe -Algorithm SHA256
$SHA32 = $TABLE32.Hash

$content = "`$packageName = 'tartube'
`$installerType = 'EXE'
`$url = 'https://github.com/axcore/tartube/releases/download/v$tag/install-tartube-$tag-32bit.exe'
`$checksum = '$SHA32'
`$url64 = 'https://github.com/axcore/tartube/releases/download/v$tag/install-tartube-$tag-64bit.exe'
`$checksum64 = '$SHA64'
`$checkumType = 'sha256'
`$silentArgs = '/S'
`$validExitCodes = @(0)
Install-ChocolateyPackage `"`$packageName`" `"`$installerType`" `"`$silentArgs`" `"`$url`" `"`$url64`" -checksum `$checksum `$checksum64 -checksumType `$checkumType -validExitCodes `$validExitCodes " | out-file -filepath ./tartube/tools/chocolateyinstall.ps1

Remove-Item tartube64.exe
Remove-Item tartube32.exe
Remove-Item release.txt

choco pack ./tartube/tartube.nuspec --outputdirectory .\tartube

If ($LastExitCode -eq 0) {
	choco push ./tartube/tartube.$tag.nupkg --source https://push.chocolatey.org/
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}

If ($LastExitCode -eq 0) {

#git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - Tartube" --allow-empty
git tag -a tartube-v$tag -m "Tartube - version $tag"
git push -f && git push --tags

#create release
Install-Module -Name New-GitHubRelease -Force
Import-Module -Name New-GitHubRelease
$newGitHubReleaseParameters = @{
GitHubUsername = "A-d-r-i"
GitHubRepositoryName = "update_choco_package"
GitHubAccessToken = "$env:ACTIONS_TOKEN"
ReleaseName = "Tartube v$tag"
TagName = "tartube-v$tag"
ReleaseNotes = "$release"
AssetFilePaths = ".\tartube\tartube.$tag.nupkg"
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
Send-TwitterStatuses_Update -status "Tartube v$tag push now on @chocolateynuget! 

Link: https://community.chocolatey.org/packages/tartube/$tag
#tartube #release #opensource
"
}
} else {
	echo "Error in choco push - Exit code: $LastExitCode "
}
