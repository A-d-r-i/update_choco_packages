$ErrorActionPreference = 'Stop'
$toolsDir = Split-Path $MyInvocation.MyCommand.Definition
$packageArgs = @{
  packageName    = 'tenacity'
  fileType       = 'exe'
  file           = "\tenacity-win-3.0.4-x86.exe"
  file64         = "\tenacity-win-3.0.4-x64.exe"
  silentArgs     = '/VERYSILENT'
  validExitCodes = @(0, 1223)
}
Install-ChocolateyInstallPackage @packageArgs
Get-ChildItem "\*.$($packageArgs.fileType)" | ForEach-Object {
  Remove-Item $_ -ea 0
  if (Test-Path $_) {
    Set-Content ".ignore"
  }
}
$packageName = $packageArgs.packageName
$installLocation = Get-AppInstallLocation $packageName
if ($installLocation) {
  Write-Host "$packageName installed to '$installLocation'"
  Register-Application "$installLocation\$packageName.exe"
  Write-Host "$packageName registered as $packageName"
}
else { Write-Warning "Can't find $PackageName install location" } 
