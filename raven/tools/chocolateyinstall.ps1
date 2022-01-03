$ErrorActionPreference = 'Stop';

$packageArgs = @{
  packageName = 'raven'
  installerType = 'EXE'
  url = 'https://github.com/hello-efficiency-inc/raven-reader/releases/download/v1.0.69/Raven-Reader-Setup-1.0.69.exe'
  checksum = 'DD8C689A7E5CD110E6DCF2A70279A8131FCE481B263794182413547F11BEB2B3'
  checkumType = 'sha256'
  silentArgs = '/S'
  validExitCodes = @(0)
}

Install-ChocolateyInstallPackage @packageArgs 
