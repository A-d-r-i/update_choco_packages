$packageName = 'l0phtcrack'
$installerType = 'EXE'
$url = 'https://l0phtcrack.gitlab.io/releases/7.2.0/lc7setup_v7.2.0_Win32.exe'
$checksum = '2E07A89CE13D23202EC9680D01DFA714DF1330A92B99EC360C7927A86F09ED35'
$url64 = 'https://l0phtcrack.gitlab.io/releases/7.2.0/lc7setup_v7.2.0_Win64.exe'
$checksum64 = 'B52EDCD72F4D7B14D59456641821810860F19BD0B21D73CC2E7165C2270D55A9'
$checkumType = 'sha256'
$silentArgs = '/S'
$validExitCodes = @(0)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" "$url64" -checksum $checksum $checksum64 -checksumType $checkumType -validExitCodes $validExitCodes 
