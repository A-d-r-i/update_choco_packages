# $tag = (Invoke-WebRequest "https://api.github.com/repos/tenacityteam/tenacity/releases/latest" | ConvertFrom-Json)[0].name
# $release = (Invoke-WebRequest "https://api.github.com/repos/tenacityteam/tenacity/releases/latest" | ConvertFrom-Json)[0].body

# $file = "./tenacity/tenacity.nuspec"
# $xml = New-Object XML
# $xml.Load($file)
# $xml.package.metadata.version = $tag
# $xml.package.metadata.releaseNotes = $release
# $xml.Save($file)

$tag = "3.0.4-beta"

Invoke-WebRequest -Uri "https://nightly.link/tenacityteam/tenacity/workflows/cmake_build/master/Tenacity_windows-server-2019-amd64-x64_windows-ninja_1277022950_.zip" -OutFile "tenacity64.zip"
Invoke-WebRequest -Uri "https://nightly.link/tenacityteam/tenacity/workflows/cmake_build/master/Tenacity_windows-server-2019-x86-x86_windows-ninja_1277022950_.zip" -OutFile "tenacity32.zip"

Expand-Archive tenacity64.zip -DestinationPath .\tenacity\tools\ -Force
Expand-Archive tenacity32.zip -DestinationPath .\tenacity\tools\ -Force

$content = "`$ErrorActionPreference = 'Stop'
`$toolsDir = `"`$(Split-Path -parent `$MyInvocation.MyCommand.Definition)`"
`$filePath = if ((Get-OSArchitectureWidth 64) -and `$env:chocolateyForceX86 -ne `$true) {
       Write-Host `"Installing 64 bit version`" ; Get-Item `$toolsDir\tenacity-win-3.0.4-x64.exe }
else { Write-Host `"Installing 32 bit version`" ; Get-Item `$toolsDir\tenacity-win-3.0.4-x86.exe }
`$packageArgs = @{
  packageName    = 'tenacity'
  fileType       = 'exe'
  softwareName   = 'tenacity*'
  file           = $filePath
  silentArgs     = '/S'
  validExitCodes = @(0)
}
Install-ChocolateyInstallPackage @packageArgs
Remove-Item `$toolsDir\*.exe -ea 0 -force " | out-file -filepath ./tenacity/tools/chocolateyinstall.ps1

Remove-Item tenacity64.zip
Remove-Item tenacity32.zip

choco pack ./tenacity/tenacity.nuspec --outputdirectory .\tenacity

If ($LastExitCode -eq 0) {
	choco push ./tenacity/tenacity.$tag.nupkg --source https://push.chocolatey.org/
} else {
 'Error - Exit code: $LastExitCode'
}
