Invoke-WebRequest -Uri "https://www.mendeley.com/release-notes-reference-manager" -OutFile "MRM.html"
Invoke-WebRequest -Uri "https://www.mendeley.com/release-notes-reference-manager" -OutFile "release.html"
$Source = Get-Content -path MRM.html -raw
$text = Get-Content -path release.html
$Source -match '<div class="views-field views-field-title"><span class="field-content"><a href="/release-notes-reference-manager/v([0-9]+(\.[0-9]+)+)">Reference Manager'
$tag = $matches[1]

$pattern = '<div class="views-field views-field-body"><div class="field-content">(.*?)</ul></div></div><div class="views-field views-field-field-content-items">'
$result = [regex]::match($text, $pattern).Groups[1].Value

$release = $result -replace 'Â', ''
$release = $release -replace '> <', '><'
$release = $release -replace '<p>', '# '
$release = $release -replace '</p>', "`n"
$release = $release -replace '</ul>', "`n"
$release = $release -replace '<ul><li>', '* '
$release = $release -replace '</li>', ''
$release = $release -replace '<li>', "`n* "
$release = -join($release, "`n`n**Full changelog:** [https://www.mendeley.com/release-notes-reference-manager/v$tag](https://www.mendeley.com/release-notes-reference-manager/v$tag)");


$file = "./mendeley-reference-manager/mendeley-reference-manager.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://static.mendeley.com/bin/desktop/mendeley-reference-manager-$tag.exe" -OutFile "./mendeley-reference-manager/tools/mendeley-reference-manager.exe"

Remove-Item release.html

choco pack ./mendeley-reference-manager/mendeley-reference-manager.nuspec --outputdirectory .\mendeley-reference-manager

If ($LastExitCode -eq 0) {
	#choco push ./mendeley-reference-manager/mendeley-reference-manager.$tag.nupkg --source https://push.chocolatey.org/
} else {
 'Error - Exit code: $LastExitCode'
}

#git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - Mendeley - RM" --allow-empty
git tag -a mendeley-rm-v$tag -m "Mendeley-Reference-Manager - version $tag"
git push -f && git push --tags

#create release
Install-Module -Name New-GitHubRelease -Force
Import-Module -Name New-GitHubRelease
$newGitHubReleaseParameters = @{
GitHubUsername = "A-d-r-i"
GitHubRepositoryName = "update_choco_package"
GitHubAccessToken = "$env:ACTIONS_TOKEN"
ReleaseName = "Mendeley-Reference-Manager v$tag"
TagName = "mendeley-rm-v$tag"
ReleaseNotes = "$release"
AssetFilePaths = ".\mendeley-reference-manager\mendeley-reference-manager.$tag.nupkg"
IsPreRelease = $false
IsDraft = $false
}
$resultrelease = New-GitHubRelease @newGitHubReleaseParameters
