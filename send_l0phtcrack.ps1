# variables
$id = "l0phtcrack"
$name = "L0phtCrack"
$accounts = "L0phtCrackLLC"
$tags = "#l0phtcrack"

# extract latest version and release
$tag = (Invoke-WebRequest "https://gitlab.com/api/v4/projects/28508791/releases" | ConvertFrom-Json)[0].tag_name
$release = (Invoke-WebRequest "https://gitlab.com/api/v4/projects/28508791/releases" | ConvertFrom-Json)[0].description

# write new version and release
$file = "./$id/$id.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

$tag32 = -join($tag,"_Win32");
$tag64 = -join($tag,"_Win64");

# download installer and LICENSE
Invoke-WebRequest -Uri "https://l0phtcrack.gitlab.io/releases/$tag/lc7setup_v$tag32.exe" -OutFile "l0phtcrack32.exe"
Invoke-WebRequest -Uri "https://l0phtcrack.gitlab.io/releases/$tag/lc7setup_v$tag64.exe" -OutFile "l0phtcrack64.exe"
Invoke-WebRequest -Uri "https://gitlab.com/l0phtcrack/l0phtcrack/-/raw/main/LICENSE.MIT" -OutFile "./$id/legal/LICENSE.txt"

# calculation of checksum
$TABLE64 = Get-FileHash l0phtcrack64.exe -Algorithm SHA256
$SHA64 = $TABLE64.Hash

$TABLE32 = Get-FileHash l0phtcrack32.exe -Algorithm SHA256
$SHA32 = $TABLE32.Hash

$content = "`$ErrorActionPreference = 'Stop';

`$packageArgs = @{
  packageName = '$id'
  installerType = 'EXE'
  url = 'https://l0phtcrack.gitlab.io/releases/$tag/lc7setup_v$tag32.exe'
  checksum = '$SHA32'
  url64 = 'https://l0phtcrack.gitlab.io/releases/$tag/lc7setup_v$tag64.exe'
  checksum64 = '$SHA64'
  checkumType = 'sha256'
  silentArgs = '/S'
  validExitCodes = @(0)
}

Install-ChocolateyInstallPackage @packageArgs " | out-file -filepath "./$id/tools/chocolateyinstall.ps1"

Remove-Item l0phtcrack64.exe
Remove-Item l0phtcrack32.exe

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official gitlab repository listed on <https://gitlab.com/l0phtcrack/l0phtcrack/-/releases>
and can be verified like this:

1. Download the following installer:
  Version $tag 32 bits : <https://l0phtcrack.gitlab.io/releases/$tag/lc7setup_v$tag32.exe>
  Version $tag 64 bits : <https://l0phtcrack.gitlab.io/releases/$tag/lc7setup_v$tag64.exe>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum 32 bits: $SHA32
  checksum 64 bits: $SHA64

File 'LICENSE.txt' is obtained from <https://gitlab.com/l0phtcrack/l0phtcrack/-/blob/main/LICENSE.MIT> " | out-file -filepath "./$id/legal/VERIFICATION.txt"

# packaging
choco pack "./$id/$id.nuspec" --outputdirectory ".\$id"

If ($LastExitCode -eq 0) {
	choco push "./$id/$id.$tag.nupkg" --source https://push.chocolatey.org/
	./END.ps1
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}