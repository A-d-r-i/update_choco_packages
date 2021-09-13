$packageName = 'raven'
$installerType = 'EXE'
$url = 'https://github.com/hello-efficiency-inc/raven-reader/releases/download/v1.0.66/Raven-Reader-Setup-1.0.66.exe'
$checksum = '2ABE0E179AD2D66D52566FD6F82C8C6FF58E5ED2B360B9CEB30655E02806B13E'
$checkumType = 'sha256'
$silentArgs = '/S'
$validExitCodes = @(0)
Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" -checksum $checksum -checksumType $checkumType -validExitCodes $validExitCodes 
