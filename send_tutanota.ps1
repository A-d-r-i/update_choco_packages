$tag = (Invoke-WebRequest "https://api.github.com/repos/tutao/tutanota/releases/latest" | ConvertFrom-Json)[0].name
$release = (Invoke-WebRequest "https://api.github.com/repos/tutao/tutanota/releases/latest" | ConvertFrom-Json)[0].body

$regex = '([0-9]{4,})'
$release = $release -replace $regex, '[${1}]https://github.com/tutao/tutanota/issues/${1})'

$file = "./tutanota/tutanota.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://mail.tutanota.com/desktop/tutanota-desktop-win.exe" -OutFile "./tutanota/tools/tutanota-desktop-win.exe"

choco pack ./tutanota/tutanota.nuspec --outputdirectory .\tutanota

If ($LastExitCode -eq 0) {
	choco push ./tutanota/tutanota.$tag.nupkg --source https://push.chocolatey.org/
} else {
 'Error - Exit code: $LastExitCode'
}
