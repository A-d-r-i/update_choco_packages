$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName   = 'firedm'
  checksum = '750248911F5F7F7355FC7DD40F7AC316A6FD9D14B12D02237D323193AF9F3C5C'
  checksumType = 'sha256'
  Url = 'https://github.com/firedm/FireDM/releases/download/2021.12.23/FireDM_2021.12.23.zip'
  UnzipLocation = $toolsDir
}

Install-ChocolateyZipPackage @packageArgs

Install-ChocolateyShortcut -ShortcutFilePath "$($env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\FireDM.lnk" -TargetPath "$toolsDir\FireDM\firedm.exe"
Install-ChocolateyShortcut -ShortcutFilePath "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))\FireDM.lnk" -TargetPath "$toolsDir\FireDM\firedm.exe" 
