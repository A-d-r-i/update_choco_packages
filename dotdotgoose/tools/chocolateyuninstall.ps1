$ErrorActionPreference = 'Stop';

Remove-Item -Path "$($env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\DotDotGoose.lnk" -Force
Remove-Item -Path "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))\DotDotGoose.lnk" -Force

Uninstall-BinFile -Name dotdotgoose
