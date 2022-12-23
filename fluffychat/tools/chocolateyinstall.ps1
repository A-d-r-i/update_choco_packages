$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName   = 'fluffychat'
  checksum = 'DE053671FBF5C4CDC5D98811C6FE0126C1C8F2E7DB55883AE9AA3FBAEC9F6E1C'
  checksumType = 'sha256'
  Url = 'https://gitlab.com/api/v4/projects/16112282/packages/generic/fluffychat/1.7.3/fluffychat-windows.zip'
  UnzipLocation = $toolsDir
}

Install-ChocolateyZipPackage @packageArgs

Install-ChocolateyShortcut -ShortcutFilePath "$($env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\FluffyChat.lnk" -TargetPath "$toolsDir\fluffychat.exe"
Install-ChocolateyShortcut -ShortcutFilePath "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))\FluffyChat.lnk" -TargetPath "$toolsDir\fluffychat.exe" 
