# variables
$id = "saucedacity"
$name = "Saucedacity"
$accounts = "@TenacityAudio"
$tags = "#saucedacity #tenacity"

# extract latest version and release
$tag = (Invoke-WebRequest "https://api.github.com/repos/tenacityteam/saucedacity/releases/latest" -Headers $headers | ConvertFrom-Json)[0].tag_name
$tag = $tag.Trim("v")
$release = (Invoke-WebRequest "https://api.github.com/repos/tenacityteam/saucedacity/releases/latest" -Headers $headers | ConvertFrom-Json)[0].body

# write new version and release
$file = "./$id/$id.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

# download installer and LICENSE
Invoke-WebRequest -Uri "https://github.com/tenacityteam/saucedacity/releases/download/v$tag/saucedacity-$tag-win-x86_64.zip" -OutFile "saucedacity64.zip"
Expand-Archive "saucedacity64.zip"
Move-Item –Path ".\saucedacity64\saucedacity-win-$tag-x64.exe" -Destination ".\$id\tools\"
Rename-Item -Path ".\$id\tools\saucedacity-win-$tag-x64.exe" -NewName "saucedacity64.exe"


Invoke-WebRequest -Uri "https://github.com/tenacityteam/saucedacity/releases/download/v1.2.1/saucedacity-1.2.1-win-x86.zip" -OutFile "saucedacity32.zip"
Expand-Archive "saucedacity32.zip"
Move-Item –Path ".\saucedacity32\saucedacity-win-$tag-x86.exe" -Destination ".\$id\tools\"
Rename-Item -Path ".\$id\tools\saucedacity-win-$tag-x86.exe" -NewName "saucedacity32.exe"


Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tenacityteam/saucedacity/main/LICENSE.txt" -OutFile "./$id/legal/LICENSE.txt"

Remove-Item "saucedacity64*" -Recurse
Remove-Item "saucedacity32*" -Recurse

# calculation of checksum
$TABLE64 = Get-FileHash "./$id/tools/saucedacity64.exe" -Algorithm SHA256
$SHA64 = $TABLE64.Hash

$TABLE32 = Get-FileHash "./$id/tools/saucedacity32.exe" -Algorithm SHA256
$SHA32 = $TABLE32.Hash

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official github repository listed on <https://github.com/tenacityteam/saucedacity/releases/>
and can be verified like this:

1. Download the following installer:
  Version $tag 64 bits : <https://github.com/tenacityteam/saucedacity/releases/download/v$tag/saucedacity-$tag-win-x86_64.zip>
  Version $tag 32 bits : <https://github.com/tenacityteam/saucedacity/releases/download/v1.2.1/saucedacity-1.2.1-win-x86.zip>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum 64 bits: $SHA64
  checksum 32 bits: $SHA32

File 'LICENSE.txt' is obtained from <https://raw.githubusercontent.com/tenacityteam/saucedacity/main/LICENSE.txt> " | out-file -filepath "./$id/legal/VERIFICATION.txt"

# packaging
choco pack "./$id/$id.nuspec" --outputdirectory ".\$id"

If ($LastExitCode -eq 0) {
	choco push "./$id/$id.$tag.nupkg" --source https://push.chocolatey.org/
	./END.ps1
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}
