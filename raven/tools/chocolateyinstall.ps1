$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$fileLocation = Join-Path $toolsDir 'raven.exe'


$packageArgs = @{
  packageName   = 'raven'
  unzipLocation = $toolsDir
  file           = $fileLocation
  fileType      = 'EXE'
  silentArgs     = '/S'
  softwareName  = 'raven*'
  validExitCodes= @(0)
}

Install-ChocolateyInstallPackage @packageArgs
Remove-Item $toolsDir\*.exe -ea 0 -force
