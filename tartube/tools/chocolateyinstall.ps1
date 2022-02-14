$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$fileLocation = Join-Path $toolsDir 'tartube32.exe'
$fileLocation64 = Join-Path $toolsDir 'tartube64.exe'

$packageArgs = @{
  packageName   = 'tartube'
  unzipLocation = $toolsDir
  file           = $fileLocation
  file64         = $fileLocation64
  fileType      = 'EXE'
  silentArgs     = '/S'
  softwareName  = 'tartube*'
  validExitCodes= @(0)
}

Install-ChocolateyInstallPackage @packageArgs