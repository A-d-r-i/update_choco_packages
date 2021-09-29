$tag = (Invoke-WebRequest "https://api.github.com/repos/CTemplar/webclient/releases/latest" | ConvertFrom-Json)[0].name
$release = (Invoke-WebRequest "https://api.github.com/repos/CTemplar/webclient/releases/latest" | ConvertFrom-Json)[0].body

$file = "./ctemplar/ctemplar"
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
 'Error - Exit code: $LastExitCode'
}
