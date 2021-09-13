Invoke-WebRequest -Uri "https://www.mendeley.com/release-notes-reference-manager" -OutFile "MRM.html"
$Source = Get-Content -path MRM.html -raw
$Source -match '<div class="views-field views-field-title"><span class="field-content"><a href="/release-notes-reference-manager/v([0-9]+(\.[0-9]+)+)">Reference Manager'
$tag = $matches[1]

$file = "./mendeley-reference-manager/mendeley-reference-manager.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.Save($file)

Invoke-WebRequest -Uri "https://static.mendeley.com/bin/desktop/mendeley-reference-manager-$tag.exe" -OutFile "./mendeley-reference-manager/tools/mendeley-reference-manager.exe"

choco pack ./mendeley-reference-manager/mendeley-reference-manager.nuspec --outputdirectory .\mendeley-reference-manager

If ($LastExitCode -eq 0) {
	choco push ./mendeley-reference-manager/mendeley-reference-manager.$tag.nupkg --source https://push.chocolatey.org/
} else {
 'Error'
}

Remove-Item MRM.html

Start-Sleep -Seconds 10
