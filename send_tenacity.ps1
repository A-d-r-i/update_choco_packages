# variables
$id = "tenacity"
$name = "Tenacity"
$accounts = "@TenacityAudio"
$tags = "#tenacity"

# extract latest version and release
# $tag = (Invoke-WebRequest "https://api.github.com/repos/tenacityteam/tenacity/releases/latest" -Headers $headers | ConvertFrom-Json)[0].name
# $release = (Invoke-WebRequest "https://api.github.com/repos/tenacityteam/tenacity/releases/latest" -Headers $headers | ConvertFrom-Json)[0].body
Invoke-WebRequest -Uri "https://nightly.link/tenacityteam/tenacity/workflows/cmake_build/master" -OutFile "tenacity.html"
$Source = Get-Content -path tenacity.html -raw
$Source -match 'Tenacity_windows-server-2019-amd64-x64_windows-ninja(_[0-9]+_)'
$run = $matches[1]

$tag = "0.1.0.001-alpha"

# write new version and release
$file = "./$id/$id.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
# $xml.package.metadata.releaseNotes = $release
$xml.Save($file)

# download installer and LICENSE
Invoke-WebRequest -Uri "https://nightly.link/tenacityteam/tenacity/workflows/cmake_build/master/Tenacity_windows-server-2019-amd64-x64_windows-ninja$run.zip" -OutFile "tenacity64.zip"
Invoke-WebRequest -Uri "https://nightly.link/tenacityteam/tenacity/workflows/cmake_build/master/Tenacity_windows-server-2019-x86-x86_windows-ninja$run.zip" -OutFile "tenacity32.zip"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tenacityteam/tenacity/master/LICENSE.txt" -OutFile "./$id/legal/LICENSE.txt"

Expand-Archive tenacity64.zip -DestinationPath ".\$id\tools\" -Force
Expand-Archive tenacity32.zip -DestinationPath ".\$id\tools\" -Force
Rename-Item -Path ".\$id\tools\tenacity-win-3.0.4-x64.exe" -NewName "tenacity64.exe"
Rename-Item -Path ".\$id\tools\tenacity-win-3.0.4-x86.exe" -NewName "tenacity32.exe"

$content = "`$ErrorActionPreference = 'Stop'
`$toolsDir = Split-Path `$MyInvocation.MyCommand.Definition
`$packageArgs = @{
  packageName    = '$id'
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
else { Write-Warning `"Can't find `$PackageName install location`" } " | out-file -filepath "./$id/tools/chocolateyinstall.ps1"

Remove-Item tenacity64.zip
Remove-Item tenacity32.zip

# calculation of checksum
$TABLE64 = Get-FileHash "./$id/tools/tenacity64.exe" -Algorithm SHA256
$SHA64 = $TABLE64.Hash

$TABLE32 = Get-FileHash "./$id/tools/tenacity32.exe" -Algorithm SHA256
$SHA32 = $TABLE32.Hash

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official github repository listed on <https://github.com/tenacityteam/tenacity/releases/>
and can be verified like this:

1. Download the following installer:
  Version $tag 32 bits : <https://nightly.link/tenacityteam/tenacity/workflows/cmake_build/master/Tenacity_windows-server-2019-x86-x86_windows-ninja$run.zip>
  Version $tag 64 bits : <https://nightly.link/tenacityteam/tenacity/workflows/cmake_build/master/Tenacity_windows-server-2019-amd64-x64_windows-ninja$run.zip>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum 32 bits: $SHA32
  checksum 64 bits: $SHA64

File 'LICENSE.txt' is obtained from <https://raw.githubusercontent.com/tenacityteam/tenacity/master/LICENSE.txt> " | out-file -filepath "./$id/legal/VERIFICATION.txt"

# packaging
choco pack "./$id/$id.nuspec" --outputdirectory ".\$id"

If ($LastExitCode -eq 0) {
	choco push "./$id/$id.$tag.nupkg" --source https://push.chocolatey.org/
	./END.ps1
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}