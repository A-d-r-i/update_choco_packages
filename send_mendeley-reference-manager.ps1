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
$release = $release -replace '<li>', "`n*"
$release = -join($release, "`nFull changelog: [https://www.mendeley.com/release-notes-reference-manager/v$tag](https://www.mendeley.com/release-notes-reference-manager/v$tag)");


$file = "./mendeley-reference-manager/mendeley-reference-manager.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://static.mendeley.com/bin/desktop/mendeley-reference-manager-$tag.exe" -OutFile "./mendeley-reference-manager/tools/mendeley-reference-manager.exe"

choco pack ./mendeley-reference-manager/mendeley-reference-manager.nuspec --outputdirectory .\mendeley-reference-manager

If ($LastExitCode -eq 0) {
	choco push ./mendeley-reference-manager/mendeley-reference-manager.$tag.nupkg --source https://push.chocolatey.org/
} else {
 'Error'
}

Start-Sleep -Seconds 10
