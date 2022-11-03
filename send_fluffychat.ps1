# variables
$id = "fluffychat"
$name = "FluffyChat"
$accounts = ""
$tags = "#fluffychat"

# extract latest version and release
$tag = (Invoke-WebRequest "https://gitlab.com/api/v4/projects/16112282/releases" | ConvertFrom-Json)[0].tag_name
$tag = $tag -replace 'v'

Invoke-WebRequest -Uri "https://gitlab.com/famedly/fluffychat/-/raw/main/CHANGELOG.md" -OutFile "FC.md"
$text = Get-Content -path FC.md
$pattern = '##(.*?)##'
$result = [regex]::match($text, $pattern).Groups[1].Value
$release = $result -replace '^','##'
$release = $release -replace "(- [0-9]{4}-[0-9]{2}-[0-9]{2} )","$&`n"
$release = $release -replace "- [a-zA-Z]","`n $&"
$release = -join($release, "`n`n**Full changelog:** [https://gitlab.com/famedly/fluffychat/-/blob/main/CHANGELOG.md](https://gitlab.com/famedly/fluffychat/-/blob/main/CHANGELOG.md) ");

# write new version and release
$file = "./$id/$id.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

# download installer and LICENSE
Invoke-WebRequest -Uri "https://gitlab.com/api/v4/projects/16112282/packages/generic/fluffychat/$tag/fluffychat-windows.zip" -OutFile "$id.zip"
Invoke-WebRequest -Uri "https://gitlab.com/famedly/fluffychat/-/raw/main/LICENSE" -OutFile "./$id/legal/LICENSE.txt"

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
  Url = 'https://gitlab.com/api/v4/projects/16112282/packages/generic/fluffychat/$tag/fluffychat-windows.zip'
  UnzipLocation = `$toolsDir
}

Install-ChocolateyZipPackage @packageArgs

Install-ChocolateyShortcut -ShortcutFilePath `"`$(`$env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\FluffyChat.lnk`" -TargetPath `"`$toolsDir\fluffychat.exe`"
Install-ChocolateyShortcut -ShortcutFilePath `"`$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))\FluffyChat.lnk`" -TargetPath `"`$toolsDir\fluffychat.exe`" " | out-file -filepath "./$id/tools/chocolateyinstall.ps1"

Remove-Item FC.md
Remove-Item $id.zip

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official gitlab repository listed on <https://gitlab.com/famedly/fluffychat/-/releases>
and can be verified like this:

1. Download the following installer:
  Version $tag : <https://gitlab.com/api/v4/projects/16112282/packages/generic/fluffychat/$tag/fluffychat-windows.zip>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum: $SHA

File 'LICENSE.txt' is obtained from <https://gitlab.com/famedly/fluffychat/-/raw/main/LICENSE> " | out-file -filepath "./$id/legal/VERIFICATION.txt"

# packaging
choco pack "./$id/$id.nuspec" --outputdirectory ".\$id"

If ($LastExitCode -eq 0) {
	choco push "./$id/$id.$tag.nupkg" --source https://push.chocolatey.org/
	./END.ps1
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}