$ErrorActionPreference = 'Stop';

Remove-Item -Path "$($env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\ctemplar.lnk" -Force
Remove-Item -Path "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))\ctemplar.lnk" -Force

Uninstall-BinFile -Name ctemplar
