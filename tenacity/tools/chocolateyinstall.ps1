$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$filePath = if ((Get-OSArchitectureWidth 64) -and $env:chocolateyForceX86 -ne $true) {
       Write-Host "Installing 64 bit version" ; Get-Item $toolsDir\tenacity-win-3.0.4-x64.exe }
else { Write-Host "Installing 32 bit version" ; Get-Item $toolsDir\tenacity-win-3.0.4-x86.exe }
$packageArgs = @{
  packageName    = 'tenacity'
  fileType       = 'exe'
  softwareName   = 'tenacity*'
  file           = 
  silentArgs     = '/S'
  validExitCodes = @(0)
}
Install-ChocolateyInstallPackage @packageArgs
Remove-Item $toolsDir\*.exe -ea 0 -force 
