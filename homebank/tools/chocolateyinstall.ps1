$ErrorActionPreference = 'Stop';

$packageArgs = @{
  packageName = 'homebank'
  installerType = 'EXE'
  url = 'http://homebank.free.fr/public/HomeBank-5.5.4-setup.exe'
  checksum = 'D105FB34B9A78C0FACE50CCF718F778FEF5A55167BF23BD03E9932206E9C9881'
  checkumType = 'sha256'
  silentArgs = '/verysilent /allusers'
  validExitCodes = @(0)
}

Install-ChocolateyInstallPackage @packageArgs 
