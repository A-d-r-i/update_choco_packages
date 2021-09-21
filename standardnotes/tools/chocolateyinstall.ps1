$packageName = 'standardnotes-desktop'
$installerType = 'EXE'
$url = 'https://github.com/standardnotes/desktop/releases/download/v3.8.21/standard-notes-3.8.21-win.exe'
$checksum = '0DD0397EAE51140D07A8CA3E4FDB7B0A1F1599F835CCFE1EADDAC76D82BCC638'
$checkumType = 'sha256'

$silentArgs = '/S'
$validExitCodes = @(0)
Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" -checksum $checksum -checksumType $checkumType -validExitCodes $validExitCodes
