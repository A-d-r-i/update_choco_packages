$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$fileLocation = Join-Path $toolsDir 'affine-client.msi'


$packageArgs = @{
  packageName   = 'affine-client'
  unzipLocation = $toolsDir
  file           = $fileLocation
  fileType      = 'MSI'
  silentArgs     = '/S'
  softwareName  = 'affine-client*'
  validExitCodes= @(0)
}

Install-ChocolateyInstallPackage @packageArgs
Remove-Item $toolsDir\*.exe -ea 0 -force