$tag = (Invoke-WebRequest "https://api.github.com/repos/hello-efficiency-inc/raven-reader/releases/latest" | ConvertFrom-Json)[0].name
$tag = $tag -replace 'v'
$release = (Invoke-WebRequest "https://api.github.com/repos/hello-efficiency-inc/raven-reader/releases/latest" | ConvertFrom-Json)[0].body

$file = "./raven/raven.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://github.com/hello-efficiency-inc/raven-reader/releases/download/v$tag/Raven-Reader-Setup-$tag.exe" -OutFile "raven.exe"

$TABLE = Get-FileHash raven.exe -Algorithm SHA256
$SHA = $TABLE.Hash

$content = "`$packageName = 'raven'
`$installerType = 'EXE'
`$url = 'https://github.com/hello-efficiency-inc/raven-reader/releases/download/v$tag/Raven-Reader-Setup-$tag.exe'
`$checksum = '$SHA'
`$checkumType = 'sha256'
`$silentArgs = '/S'
`$validExitCodes = @(0)
Install-ChocolateyPackage `"`$packageName`" `"`$installerType`" `"`$silentArgs`" `"`$url`" -checksum `$checksum -checksumType `$checkumType -validExitCodes `$validExitCodes " | out-file -filepath ./raven/tools/chocolateyinstall.ps1

Remove-Item raven.exe

choco pack ./raven/raven.nuspec --outputdirectory .\raven


If ($LastExitCode -eq 0) {
	choco push ./raven/raven.$tag.nupkg --source https://push.chocolatey.org/
} else {
 'Error'
}

Start-Sleep -Seconds 10
