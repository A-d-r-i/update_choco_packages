# variables
$id = "firedm"
$name = "FireDM"
$accounts = ""
$tags = "#FireDM"

# extract latest version and release
$tag = (Invoke-WebRequest "https://api.github.com/repos/firedm/FireDM/releases/latest" | ConvertFrom-Json)[0].tag_name
$release = (Invoke-WebRequest "https://api.github.com/repos/firedm/FireDM/releases/latest" | ConvertFrom-Json)[0].body

$regex = '#([0-9]{3,})'
$release = $release -replace $regex, '[#${1}](https://github.com/firedm/FireDM/issues/${1})'

# write new version and release
$file = "./$id/$id.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

# download installer and LICENSE
Invoke-WebRequest -Uri "https://github.com/firedm/FireDM/releases/download/$tag/FireDM_$tag.zip" -OutFile "$id.zip"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/firedm/FireDM/master/LICENSE" -OutFile "./$id/legal/LICENSE.txt"

# calculation of checksum
$TABLE = Get-FileHash "$id.zip" -Algorithm SHA256
$SHA = $TABLE.Hash

# writing of chocolateyinstall.ps1
$content = "`$ErrorActionPreference = 'Stop';
`$toolsDir   = `"`$(Split-Path -parent `$MyInvocation.MyCommand.Definition)`"

`$packageArgs = @{
  packageName   = '$id'
  checksum = '$SHA'
  checksumType = 'sha256'
  Url = 'https://github.com/firedm/FireDM/releases/download/$tag/FireDM_$tag.zip'
  UnzipLocation = `$toolsDir
}

Install-ChocolateyZipPackage @packageArgs

Install-ChocolateyShortcut -ShortcutFilePath `"`$(`$env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\FireDM.lnk`" -TargetPath `"`$toolsDir\FireDM\firedm.exe`"
Install-ChocolateyShortcut -ShortcutFilePath `"`$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))\FireDM.lnk`" -TargetPath `"`$toolsDir\FireDM\firedm.exe`" " | out-file -filepath "./$id/tools/chocolateyinstall.ps1"

Remove-Item $id.zip

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official github repository listed on <https://github.com/firedm/FireDM/releases/>
and can be verified like this:

1. Download the following installer:
  Version $tag : <https://github.com/firedm/FireDM/releases/download/$tag/FireDM_$tag.zip>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum: $SHA

File 'LICENSE.txt' is obtained from <https://raw.githubusercontent.com/firedm/FireDM/master/LICENSE> " | out-file -filepath "./$id/legal/VERIFICATION.txt"

# packaging
choco pack "./$id/$id.nuspec" --outputdirectory ".\$id"

If ($LastExitCode -eq 0) {
	choco push "./$id/$id.$tag.nupkg" --source https://push.chocolatey.org/
	./END.ps1
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}