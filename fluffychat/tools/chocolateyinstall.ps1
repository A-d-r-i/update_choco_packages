$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName   = 'fluffychat'
  checksum = 'F10626494243FBCB6207CA86E920DF66431DA5F3A3993A66B84D43F477CF52C2'
  checksumType = 'sha256'
  Url = 'https://gitlab.com/famedly/fluffychat/-/archive/v1.6.4/fluffychat-v1.6.4.zip'
  UnzipLocation = $toolsDir
}

Install-ChocolateyZipPackage @packageArgs

Install-ChocolateyShortcut -ShortcutFilePath "$($env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\FluffyChat.lnk" -TargetPath "$toolsDir\fluffychat.exe"
Install-ChocolateyShortcut -ShortcutFilePath "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))\FluffyChat.lnk" -TargetPath "$toolsDir\fluffychat.exe" 
