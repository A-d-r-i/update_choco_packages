$packageName = 'standardnotes-desktop'
$installerType = 'EXE'
$url = 'https://github.com/standardnotes/desktop/releases/download/v3.8.21/standard-notes-3.8.21-win.exe'
$checksum = 'E3B2AA6F1F181469A79F4681EC6DB74BCA84F8D85699CD5199A00A8DD22B4C59'
$checkumType = 'sha256'
$silentArgs = '/S'
$validExitCodes = @(0)
Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" -checksum $checksum -checksumType $checkumType -validExitCodes $validExitCodes 
