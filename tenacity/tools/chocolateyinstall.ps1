$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$fileLocation = Join-Path $toolsDir 'tenacity32.exe'
$fileLocation64 = Join-Path $toolsDir 'tenacity64.exe'

$packageArgs = @{
  packageName   = 'tenacity'
  unzipLocation = $toolsDir
  file           = $fileLocation
  file64         = $fileLocation64
  fileType      = 'EXE'
  silentArgs     = '/VERYSILENT'
  softwareName  = 'tenacity*'
  validExitCodes= @(0)
}

Install-ChocolateyInstallPackage @packageArgs
Remove-Item $toolsDir\*.exe -ea 0 -force
