$ErrorActionPreference = 'Stop';

$packageArgs = @{
  packageName = 'raven'
  installerType = 'EXE'
  url = 'https://github.com/hello-efficiency-inc/raven-reader/releases/download/v1.0.68/Raven-Reader-Setup-1.0.68.exe'
  checksum = '1E3272C8A97DAF3F38133B5FDC753F175976071DC11FBC3928ECD139330B494F'
  checkumType = 'sha256'
  silentArgs = '/S'
  validExitCodes = @(0)
}

Install-ChocolateyInstallPackage @packageArgs 
