$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$fileLocation = Join-Path $toolsDir 'audiomoth-gps-sync.exe'


$packageArgs = @{
  packageName   = 'audiomoth-gps-sync'
  unzipLocation = $toolsDir
  file           = $fileLocation
  fileType      = 'EXE'
  silentArgs     = '/S'
  softwareName  = 'audiomoth-gps-sync*'
  validExitCodes= @(0)
}

Install-ChocolateyInstallPackage @packageArgs
Remove-Item $toolsDir\*.exe -ea 0 -force