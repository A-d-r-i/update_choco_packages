
$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$packageName = 'dotdotgoose'

Install-BinFile -Name $packageName -Path "$($env:ChocolateyInstall)\bin"
Install-ChocolateyShortcut -ShortcutFilePath "$($env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\DotDotGoose.lnk" -TargetPath "$($env:ChocolateyInstall)\bin\DotDotGoose.exe"
Install-ChocolateyShortcut -ShortcutFilePath "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))\DotDotGoose.lnk" -TargetPath "$($env:ChocolateyInstall)\bin\DotDotGoose.exe"