$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName   = 'firedm'
  checksum = '51E844B47291DF04A6FF9920AC172725676D0C2BFBEB8AFF4DAE108C668B0FD6'
  checksumType = 'sha256'
  Url = 'https://github.com/firedm/FireDM/releases/download/2021.11.18/FireDM_2021.11.18.zip'
  UnzipLocation = $toolsDir
}

Install-ChocolateyZipPackage @packageArgs

Install-ChocolateyShortcut -ShortcutFilePath "$($env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\FireDM.lnk" -TargetPath "$toolsDir\FireDM\firedm.exe"
Install-ChocolateyShortcut -ShortcutFilePath "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))\FireDM.lnk" -TargetPath "$toolsDir\FireDM\firedm.exe" 
