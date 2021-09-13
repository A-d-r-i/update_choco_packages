Invoke-WebRequest -Uri "http://homebank.free.fr/en/downloads.php" -OutFile "HOMEBANK.html"
$Source = Get-Content -path HOMEBANK.html -raw
$Source -match 'The latest <b>([0-9]+(\.[0-9]+)+) stable</b>'
$tag = $matches[1]

$file = "./homebank/homebank.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.Save($file)

Invoke-WebRequest -Uri "http://homebank.free.fr/public/HomeBank-$tag-setup.exe" -OutFile "homebank.exe"

$TABLE = Get-FileHash homebank.exe -Algorithm SHA256
$SHA = $TABLE.Hash

$content = "`$packageName = 'homebank'
`$installerType = 'EXE'
`$url = 'http://homebank.free.fr/public/HomeBank-$tag-setup.exe'
`$checksum = '$SHA'
`$checkumType = 'sha256'
`$silentArgs = '/verysilent /allusers'
`$validExitCodes = @(0)
Install-ChocolateyPackage `"`$packageName`" `"`$installerType`" `"`$silentArgs`" `"`$url`" -checksum `$checksum -checksumType `$checkumType -validExitCodes `$validExitCodes " | out-file -filepath ./homebank/tools/chocolateyinstall.ps1

Remove-Item homebank.exe
Remove-Item HOMEBANK.html

choco pack ./homebank/homebank.nuspec --outputdirectory .\homebank

If ($LastExitCode -eq 0) {
	choco push ./homebank/homebank.$tag.nupkg --source https://push.chocolatey.org/
} else {
 'Error'
}

Start-Sleep -Seconds 10
