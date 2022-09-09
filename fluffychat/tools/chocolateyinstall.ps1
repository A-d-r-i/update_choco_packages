$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName   = 'fluffychat'
  checksum = '4A83E63B58ADFAD3AC57983983FB3E3EFEE2444FA0AC15ADABB1FDB9D2BE41AE'
  checksumType = 'sha256'
  Url = 'https://gitlab.com/api/v4/projects/16112282/packages/generic/fluffychat/1.6.4/fluffychat-windows.zip'
  UnzipLocation = $toolsDir
}

Install-ChocolateyZipPackage @packageArgs

Install-ChocolateyShortcut -ShortcutFilePath "$($env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\FluffyChat.lnk" -TargetPath "$toolsDir\fluffychat.exe"
Install-ChocolateyShortcut -ShortcutFilePath "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))\FluffyChat.lnk" -TargetPath "$toolsDir\fluffychat.exe" 
