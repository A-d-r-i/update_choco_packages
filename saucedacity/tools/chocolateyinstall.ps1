$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$fileLocation = Join-Path $toolsDir 'saucedacity32.exe'
$fileLocation64 = Join-Path $toolsDir 'saucedacity64.exe'

$packageArgs = @{
  packageName   = 'saucedacity'
  unzipLocation = $toolsDir
  file           = $fileLocation
  file64         = $fileLocation64
  fileType      = 'EXE'
  silentArgs     = '/S'
  softwareName  = 'saucedacity*'
  validExitCodes= @(0)
}

Install-ChocolateyInstallPackage @packageArgs
Remove-Item $toolsDir\*.exe -ea 0 -force