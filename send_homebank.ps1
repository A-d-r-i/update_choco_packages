Invoke-WebRequest -Uri "http://homebank.free.fr/en/downloads.php" -OutFile "HOMEBANK.html"
Invoke-WebRequest -Uri "http://homebank.free.fr/ChangeLog" -OutFile "release.txt"
$Source = Get-Content -path HOMEBANK.html -raw
$text = Get-Content -path release.txt
$Source -match 'The latest <b>([0-9]+(\.[0-9]+)+) stable</b>'
$tag = $matches[1]


$search = "[0-9]{4}-[0-9]{2}-[0-9]{2}  Maxime Doyen"
$pattern = "$search(.*?)$search"
$result = [regex]::Match($text,$pattern).Groups[1].Value
$release = $result -replace '   :', ':'
$release = $release -replace '  :', ':'
$release = $release -replace '   *', "`n"
$release = $release -replace '  ', "`n"
$regex = '([0-9]{7,})'
$release = $release -replace $regex, '[${1}](https://bugs.launchpad.net/bugs/${1})'
$release = -join($release, "`n**Full changelog:** [http://homebank.free.fr/ChangeLog](http://homebank.free.fr/ChangeLog)");


$file = "./homebank/homebank.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "http://homebank.free.fr/public/HomeBank-$tag-setup.exe" -OutFile "homebank.exe"

$TABLE = Get-FileHash homebank.exe -Algorithm SHA256
$SHA = $TABLE.Hash

$content = "`$packageName = 'homebank'
`$installerType = 'EXE'
`$url = 'http://homebank.free.fr/public/HomeBank-$tag-setup.exe'
`$checksum = '$SHA'
`$checkumType = 'sha256'
`$silentArgs = '/verysilent /allusers'
`$validExitCodes = @(0)
Install-ChocolateyPackage `"`$packageName`" `"`$installerType`" `"`$silentArgs`" `"`$url`" -checksum `$checksum -checksumType `$checkumType -validExitCodes `$validExitCodes " | out-file -filepath ./homebank/tools/chocolateyinstall.ps1

Remove-Item homebank.exe
Remove-Item release.txt

choco pack ./homebank/homebank.nuspec --outputdirectory .\homebank

If ($LastExitCode -eq 0) {
	choco push ./homebank/homebank.$tag.nupkg --source https://push.chocolatey.org/
} else {
 'Error - Exit code: $LastExitCode'
}

#git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - homebank" --allow-empty
git tag -a homebank-v$tag -m "HomeBank - version $tag"
git push -f && git push --tags

#create release
Install-Module -Name New-GitHubRelease -Force
Import-Module -Name New-GitHubRelease
$newGitHubReleaseParameters = @{
GitHubUsername = "A-d-r-i"
GitHubRepositoryName = "update_choco_package"
GitHubAccessToken = "$env:ACTIONS_TOKEN"
ReleaseName = "HomeBank v$tag"
TagName = "homebank-v$tag"
ReleaseNotes = "$release"
AssetFilePaths = ".\homebank\homebank.$tag.nupkg"
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
ApiKey = "${{ secrets.PST_KEY }}"
ApiSecret = "${{ secrets.PST_SECRET }}"
AccessToken = "${{ secrets.PST_TOKEN }}"
AccessTokenSecret = "${{ secrets.PST_TOKEN_SECRET }}"
}
Set-TwitterOAuthSettings @OAuthSettings
Send-TwitterStatuses_Update -status "HomeBank v$tag push now on @chocolateynuget! 

Link: https://community.chocolatey.org/packages/homebank/$tag
#homebank #release #opensource
"
}
