$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName   = 'fluffychat'
  checksum = '09E11EA8675FDE587A34F1477190099BFCC2511BC61B7DC7FF9CDCF84358596A'
  checksumType = 'sha256'
  Url = 'https://gitlab.com/famedly/fluffychat/-/archive/v1.1.0/fluffychat-v1.1.0.zip'
  UnzipLocation = $toolsDir
}

Install-ChocolateyZipPackage @packageArgs

Install-ChocolateyShortcut -ShortcutFilePath "$($env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\FluffyChat.lnk" -TargetPath "$toolsDir\fluffychat.exe"
Install-ChocolateyShortcut -ShortcutFilePath "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))\FluffyChat.lnk" -TargetPath "$toolsDir\fluffychat.exe" 
