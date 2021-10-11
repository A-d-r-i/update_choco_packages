$tag = (Invoke-WebRequest "https://api.github.com/repos/CTemplar/webclient/releases/latest" | ConvertFrom-Json)[0].name
$release = (Invoke-WebRequest "https://api.github.com/repos/CTemplar/webclient/releases/latest" | ConvertFrom-Json)[0].body

$file = "./ctemplar/ctemplar.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://github.com/CTemplar/webclient/releases/download/v$tag/CTemplar-$tag.exe" -OutFile "./ctemplar/tools/ctemplar.exe"

choco pack ./ctemplar/ctemplar.nuspec --outputdirectory .\ctemplar

If ($LastExitCode -eq 0) {
	choco push ./ctemplar/ctemplar.$tag.nupkg --source https://push.chocolatey.org/
} else {
 'Error in introduction - Exit code: $LastExitCode'
}

If ($LastExitCode -eq 0) {
#git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - ctemplar" --allow-empty
git tag -a ctemplar-v$tag -m "CTemplar - version $tag"
git push -f && git push --tags

#create release
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
Send-TwitterStatuses_Update -status "CTemplar v$tag push now on @chocolateynuget! 

Link: https://community.chocolatey.org/packages/ctemplar/$tag
@RealCTemplar
#ctemplar #release #opensource
"
}
} else {
 'Error in choco push - Exit code: $LastExitCode'
}
