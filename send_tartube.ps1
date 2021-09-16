$tag = (Invoke-WebRequest "https://api.github.com/repos/axcore/tartube/releases/latest" | ConvertFrom-Json)[0].tag_name
$tag = $tag -replace 'v'
$release = (Invoke-WebRequest "https://api.github.com/repos/axcore/tartube/releases/latest" | ConvertFrom-Json)[0].body

$file = "./tartube/tartube.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://github.com/axcore/tartube/releases/download/v$tag/install-tartube-$tag-64bit.exe" -OutFile "tartube64.exe"
Invoke-WebRequest -Uri "https://github.com/axcore/tartube/releases/download/v$tag/install-tartube-$tag-32bit.exe" -OutFile "tartube32.exe"

$TABLE64 = Get-FileHash tartube64.exe -Algorithm SHA256
$SHA64 = $TABLE64.Hash

$TABLE32 = Get-FileHash tartube32.exe -Algorithm SHA256
$SHA32 = $TABLE32.Hash

$content = "`$packageName = 'tartube'
`$installerType = 'EXE'
`$url = 'https://github.com/axcore/tartube/releases/download/v$tag/install-tartube-$tag-32bit.exe'
`$checksum = '$SHA32'
`$url64 = 'https://github.com/axcore/tartube/releases/download/v$tag/install-tartube-$tag-64bit.exe'
`$checksum64 = '$SHA64'
`$checkumType = 'sha256'
`$silentArgs = '/S'
`$validExitCodes = @(0)
Install-ChocolateyPackage `"`$packageName`" `"`$installerType`" `"`$silentArgs`" `"`$url`" `"`$url64`" -checksum `$checksum `$checksum64 -checksumType `$checkumType -validExitCodes `$validExitCodes " | out-file -filepath ./tartube/tools/chocolateyinstall.ps1

Remove-Item tartube64.exe
Remove-Item tartube32.exe

choco pack ./tartube/tartube.nuspec --outputdirectory .\tartube

If ($LastExitCode -eq 0) {
	choco push ./tartube/tartube.$tag.nupkg --source https://push.chocolatey.org/
} else {
 'Error'
}

Start-Sleep -Seconds 10
