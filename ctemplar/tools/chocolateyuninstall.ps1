$ErrorActionPreference = 'Stop';

Remove-Item -Path "$($env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\CTemplar.lnk" -Force
Remove-Item -Path "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))\CTemplar.lnk" -Force

Uninstall-BinFile -Name ctemplar
