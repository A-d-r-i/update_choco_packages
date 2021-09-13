$packageName = 'tartube'
$installerType = 'EXE'
$url = 'https://github.com/axcore/tartube/releases/download/v2.3.332/install-tartube-2.3.332-32bit.exe'
$checksum = '7778354ED8D0341581EDBCF8F35453C01EB34BC2A64EAB270BBD55DF4E0D3BF0'
$url64 = 'https://github.com/axcore/tartube/releases/download/v2.3.332/install-tartube-2.3.332-64bit.exe'
$checksum64 = '9915E32BE5BC78C57C2423682594C9B2046DB2B1CF01835FB0BED2FEE6C4DFD4'
$checkumType = 'sha256'

$silentArgs = '/S'
$validExitCodes = @(0)
Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" "$url64" -checksum $checksum $checksum64 -checksumType $checkumType -validExitCodes $validExitCodes
