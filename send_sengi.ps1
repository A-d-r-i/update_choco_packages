$tag = (Invoke-WebRequest "https://api.github.com/repos/NicolasConstant/sengi/releases/latest" | ConvertFrom-Json)[0].tag_name
$release = (Invoke-WebRequest "https://api.github.com/repos/NicolasConstant/sengi/releases/latest" | ConvertFrom-Json)[0].body

$file = "./sengi/sengi.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://github.com/NicolasConstant/sengi/releases/download/$tag/Sengi-$tag-win.exe" -OutFile "./sengi/tools/sengi.exe"

choco pack ./sengi/sengi.nuspec --outputdirectory .\sengi

If ($LastExitCode -eq 0) {
	choco push ./sengi/sengi.$tag.nupkg --source https://push.chocolatey.org/
} else {
 'Error - Exit code: $LastExitCode'
}

#git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - sengi" --allow-empty
git tag -a sengi-v$tag -m "Sengi - version $tag"
git push -f && git push --tags

#create release
Install-Module -Name New-GitHubRelease -Force
Import-Module -Name New-GitHubRelease
$newGitHubReleaseParameters = @{
GitHubUsername = "A-d-r-i"
GitHubRepositoryName = "update_choco_package"
GitHubAccessToken = "$env:ACTIONS_TOKEN"
ReleaseName = "Sengi v$tag"
TagName = "sengi-v$tag"
ReleaseNotes = "$release"
AssetFilePaths = ".\sengi\sengi.$tag.nupkg"
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
Send-TwitterStatuses_Update -status "Sengi v$tag push now on @chocolateynuget! 

Link: https://community.chocolatey.org/packages/sengi/$tag
#sengi #release #opensource
"
}
