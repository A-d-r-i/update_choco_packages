$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$packageName = 'firedm'

Install-ChocolateyZipPackage -PackageName $packageName -Url 'https://github.com/firedm/FireDM/releases/download/2021.9.28/FireDM_2021.9.28.zip' -UnzipLocation $toolsDir

Install-ChocolateyShortcut -ShortcutFilePath "$($env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\FireDM.lnk" -TargetPath "$toolsDir\FireDM\firedm.exe"
Install-ChocolateyShortcut -ShortcutFilePath "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))\FireDM.lnk" -TargetPath "$toolsDir\FireDM\firedm.exe" 
