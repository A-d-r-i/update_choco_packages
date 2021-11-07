$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$packageName = 'fluffychat'
$checksum = '307800E8712919A79B095F343809B1CB8A5ABBC4C764040BA9258DDB4533570B'
$checkumType = 'sha256'

Install-ChocolateyZipPackage -PackageName $packageName -checksum $checksum -checksumType $checkumType -Url 'https://gitlab.com/api/v4/projects/16112282/packages/generic/fluffychat/0.42.0/fluffychat-windows.zip' -UnzipLocation $toolsDir

Install-ChocolateyShortcut -ShortcutFilePath "$($env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\FluffyChat.lnk" -TargetPath "$toolsDir\fluffychat.exe"
Install-ChocolateyShortcut -ShortcutFilePath "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))\FluffyChat.lnk" -TargetPath "$toolsDir\fluffychat.exe" 
