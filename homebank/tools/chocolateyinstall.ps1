$packageName = 'homebank'
$installerType = 'EXE'
$url = 'http://homebank.free.fr/public/HomeBank-5.5.3-setup.exe'
$checksum = 'BA88E3798F705531466AC67A89BE9B85A02209C442C963DF8E9F837EA2AA71F7'
$checkumType = 'sha256'
$silentArgs = '/verysilent /allusers'
$validExitCodes = @(0)
Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" -checksum $checksum -checksumType $checkumType -validExitCodes $validExitCodes 
