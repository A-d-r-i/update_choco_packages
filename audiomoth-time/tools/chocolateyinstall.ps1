$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$fileLocation = Join-Path $toolsDir 'audiomoth-time.exe'


$packageArgs = @{
  packageName   = 'audiomoth-time'
  unzipLocation = $toolsDir
  file           = $fileLocation
  fileType      = 'EXE'
  silentArgs     = '/S'
  softwareName  = 'audiomoth-time*'
  validExitCodes= @(0)
}

Install-ChocolateyInstallPackage @packageArgs
Remove-Item $toolsDir\*.exe -ea 0 -force