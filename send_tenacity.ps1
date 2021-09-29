# $tag = (Invoke-WebRequest "https://api.github.com/repos/tenacityteam/tenacity/releases/latest" | ConvertFrom-Json)[0].name
# $release = (Invoke-WebRequest "https://api.github.com/repos/tenacityteam/tenacity/releases/latest" | ConvertFrom-Json)[0].body
Invoke-WebRequest -Uri "https://nightly.link/tenacityteam/tenacity/workflows/cmake_build/master" -OutFile "tenacity.html"
$Source = Get-Content -path tenacity.html -raw
$Source -match 'Tenacity_windows-server-2019-amd64-x64_windows-ninja(_[0-9]+_)'
$run = $matches[1]

$tag = "0.1.0.001-alpha"

$file = "./tenacity/tenacity.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
# $xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://nightly.link/tenacityteam/tenacity/workflows/cmake_build/master/Tenacity_windows-server-2019-amd64-x64_windows-ninja$run.zip" -OutFile "tenacity64.zip"
Invoke-WebRequest -Uri "https://nightly.link/tenacityteam/tenacity/workflows/cmake_build/master/Tenacity_windows-server-2019-x86-x86_windows-ninja$run.zip" -OutFile "tenacity32.zip"

Expand-Archive tenacity64.zip -DestinationPath .\tenacity\tools\ -Force
Expand-Archive tenacity32.zip -DestinationPath .\tenacity\tools\ -Force
Rename-Item -Path ".\tenacity\tools\tenacity-win-3.0.4-x64.exe" -NewName "tenacity64.exe"
Rename-Item -Path ".\tenacity\tools\tenacity-win-3.0.4-x86.exe" -NewName "tenacity32.exe"

$content = "`$ErrorActionPreference = 'Stop'
`$toolsDir = Split-Path `$MyInvocation.MyCommand.Definition
`$packageArgs = @{
  packageName    = 'tenacity'
  fileType       = 'exe'
  file           = `"`$toolsDir\tenacity32.exe`"
  file64         = `"`$toolsDir\tenacity64.exe`"
  silentArgs     = '/VERYSILENT'
  validExitCodes = @(0, 1223)
}
Install-ChocolateyInstallPackage @packageArgs
Get-ChildItem `"`$toolsDir\*.`$(`$packageArgs.fileType)`" | ForEach-Object {
  Remove-Item `$_ -ea 0
  if (Test-Path `$_) {
    Set-Content `"`$_.ignore`"
  }
}
`$packageName = `$packageArgs.packageName
`$installLocation = Get-AppInstallLocation `$packageName
if (`$installLocation) {
  Write-Host `"`$packageName installed to '`$installLocation'`"
  Register-Application `"`$installLocation\`$packageName.exe`"
  Write-Host `"`$packageName registered as `$packageName`"
}
else { Write-Warning `"Can't find `$PackageName install location`" } " | out-file -filepath ./tenacity/tools/chocolateyinstall.ps1

Remove-Item tenacity64.zip
Remove-Item tenacity32.zip

choco pack ./tenacity/tenacity.nuspec --outputdirectory .\tenacity

If ($LastExitCode -eq 0) {
	choco push ./tenacity/tenacity.$tag.nupkg --source https://push.chocolatey.org/
} else {
 'Error - Exit code: $LastExitCode'
}
