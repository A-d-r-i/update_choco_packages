$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$packageName = 'ctemplar'

Install-BinFile -Name $packageName -Path "$($env:ChocolateyInstall)\bin"
Install-ChocolateyShortcut -ShortcutFilePath "$($env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\CTemplar.lnk" -TargetPath "$($env:ChocolateyInstall)\bin\ctemplar.exe"
Install-ChocolateyShortcut -ShortcutFilePath "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))\CTemplar.lnk" -TargetPath "$($env:ChocolateyInstall)\bin\ctemplar.exe"
