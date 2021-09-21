$tag = (Invoke-WebRequest "https://api.github.com/repos/standardnotes/desktop/releases/latest" | ConvertFrom-Json)[0].name
$release = (Invoke-WebRequest "https://api.github.com/repos/standardnotes/desktop/releases/latest" | ConvertFrom-Json)[0].body

$file = "./standardnotes/standardnotes.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://github.com/standardnotes/desktop/releases/download/v$tag/standard-notes-$tag-win.exe" -OutFile "standardnotes.exe"

$TABLE = Get-FileHash standardnotes.exe -Algorithm SHA256
$SHA = $TABLE.Hash

$content = "`$packageName = 'standardnotes'
`$installerType = 'EXE'
`$url = 'https://github.com/standardnotes/desktop/releases/download/v$tag/standard-notes-$tag-win.exe'
`$checksum = '$SHA'
`$checkumType = 'sha256'
`$silentArgs = '/S'
`$validExitCodes = @(0)
Install-ChocolateyPackage `"`$packageName`" `"`$installerType`" `"`$silentArgs`" `"`$url`" -checksum `$checksum -checksumType `$checkumType -validExitCodes `$validExitCodes " | out-file -filepath ./raven/tools/chocolateyinstall.ps1

Remove-Item standardnotes.exe

choco pack ./standardnotes/standardnotes.nuspec --outputdirectory .\standardnotes


If ($LastExitCode -eq 0) {
	choco push ./standardnotes/standardnotes.$tag.nupkg --source https://push.chocolatey.org/
} else {
 'Error - Exit code: $LastExitCode'
}
