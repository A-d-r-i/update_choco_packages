$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$fileLocation = Join-Path $toolsDir 'open-video-downloader.exe'


$packageArgs = @{
  packageName   = 'open-video-downloader'
  unzipLocation = $toolsDir
  file           = $fileLocation
  fileType      = 'EXE'
  silentArgs     = '/S'
  softwareName  = 'open-video-downloader*'
  validExitCodes= @(0)
}

Install-ChocolateyInstallPackage @packageArgs
Remove-Item $toolsDir\*.exe -ea 0 -force