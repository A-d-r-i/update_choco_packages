$packageName = 'homebank'
$installerType = 'EXE'
$url = 'http://homebank.free.fr/public/HomeBank-5.5.3-setup.exe'
$checksum = 'ba88e3798f705531466ac67a89be9b85a02209c442c963df8e9f837ea2aa71f7'
$checkumType = 'sha256'
$silentArgs = '/verysilent /allusers'
$validExitCodes = @(0)
Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" -checksum $checksum -checksumType $checkumType -validExitCodes $validExitCodes
