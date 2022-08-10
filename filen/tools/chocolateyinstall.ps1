$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$fileLocation = Join-Path $toolsDir 'filen.exe'


$packageArgs = @{
  packageName   = 'filen'
  unzipLocation = $toolsDir
  file           = $fileLocation
  fileType      = 'EXE'
  silentArgs     = '/S'
  softwareName  = 'filen*'
  validExitCodes= @(0)
}

Install-ChocolateyInstallPackage @packageArgs
Remove-Item $toolsDir\*.exe -ea 0 -force