$packageName = 'raven'
$installerType = 'EXE'
$url = 'https://github.com/hello-efficiency-inc/raven-reader/releases/download/v1.0.65/Raven-Reader-Setup-1.0.65.exe'
$checksum = '0DD0397EAE51140D07A8CA3E4FDB7B0A1F1599F835CCFE1EADDAC76D82BCC638'
$checkumType = 'sha256'

$silentArgs = '/S'
$validExitCodes = @(0)
Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" -checksum $checksum -checksumType $checkumType -validExitCodes $validExitCodes
