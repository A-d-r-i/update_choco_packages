$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$packageName = 'firedm'
$checksum = '8CBD695820DB70477B4BA9BD70B86F2A917EC9F0E2EB5663B29AD7ABA232B54B'
$checkumType = 'sha256'

Install-ChocolateyZipPackage -PackageName $packageName -checksum $checksum -checksumType $checkumType -Url 'https://github.com/firedm/FireDM/releases/download/2021.9.28/FireDM_2021.9.28.zip' -UnzipLocation $toolsDir

Install-ChocolateyShortcut -ShortcutFilePath "$($env:SystemDrive)\ProgramData\Microsoft\Windows\Start Menu\Programs\FireDM.lnk" -TargetPath "$toolsDir\FireDM\firedm.exe"
Install-ChocolateyShortcut -ShortcutFilePath "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))\FireDM.lnk" -TargetPath "$toolsDir\FireDM\firedm.exe" 
