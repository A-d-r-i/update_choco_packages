$packageName = 'raven'
$installerType = 'EXE'
$url = 'https://github.com/hello-efficiency-inc/raven-reader/releases/download/v1.0.67/Raven-Reader-Setup-1.0.67.exe'
$checksum = '8BC2C1DE1BA35F4C4445D04729BE0E785E93E4EBF1E6057096BB1F9361C3DF47'
$checkumType = 'sha256'
$silentArgs = '/S'
$validExitCodes = @(0)
Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" -checksum $checksum -checksumType $checkumType -validExitCodes $validExitCodes 
