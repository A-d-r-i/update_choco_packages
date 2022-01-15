$ErrorActionPreference = 'Stop';

$packageArgs = @{
  packageName = 'raven'
  installerType = 'EXE'
  url = 'https://github.com/hello-efficiency-inc/raven-reader/releases/download/v1.0.70/Raven-Reader-Setup-1.0.70.exe'
  checksum = '5383A1CF80AE774993CF4567BE26ED6E1E67ADC0A4EA8ADF034FC1245D446A40'
  checkumType = 'sha256'
  silentArgs = '/S'
  validExitCodes = @(0)
}

Install-ChocolateyInstallPackage @packageArgs 
