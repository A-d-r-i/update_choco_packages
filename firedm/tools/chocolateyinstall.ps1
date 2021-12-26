$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName   = 'firedm'
  checksum = '790E6BACE8DDB88592D0904CE020576FEC1177DAD88F9EB2147BDEE10394405F'
  checksumType = 'sha256'
  Url = 'https://github.com/firedm/FireDM/releases/download/2021.12.26/FireDM_2021.12.26.zip'
  UnzipLocation = $toolsDir
}

Install-ChocolateyZipPackage @packageArgs

Install-ChocolateyShortcut -ShortcutFilePath "$($env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\FireDM.lnk" -TargetPath "$toolsDir\FireDM\firedm.exe"
Install-ChocolateyShortcut -ShortcutFilePath "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))\FireDM.lnk" -TargetPath "$toolsDir\FireDM\firedm.exe" 
