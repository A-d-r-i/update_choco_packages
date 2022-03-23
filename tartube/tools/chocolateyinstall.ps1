$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$fileLocation = Join-Path $toolsDir 'tartube64.exe'

$packageArgs = @{
  packageName   = 'tartube'
  unzipLocation = $toolsDir
  file           = $fileLocation
  fileType      = 'EXE'
  silentArgs     = '/S'
  softwareName  = 'tartube*'
  validExitCodes= @(0)
}

Install-ChocolateyInstallPackage @packageArgs