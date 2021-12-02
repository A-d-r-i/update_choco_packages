$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName   = 'firedm'
  checksum = '9C76E0931A69D1F7D97EA81C6A504ABE87F8BA2CEB73D96EB5F6690B485029E9'
  checksumType = 'sha256'
  Url = 'https://github.com/firedm/FireDM/releases/download/2021.12.2/FireDM_2021.12.2.zip'
  UnzipLocation = $toolsDir
}

Install-ChocolateyZipPackage @packageArgs

Install-ChocolateyShortcut -ShortcutFilePath "$($env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\FireDM.lnk" -TargetPath "$toolsDir\FireDM\firedm.exe"
Install-ChocolateyShortcut -ShortcutFilePath "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))\FireDM.lnk" -TargetPath "$toolsDir\FireDM\firedm.exe" 
