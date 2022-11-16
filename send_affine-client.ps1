# variables
$id = "affine-client"
$name = "Affine-client"
$accounts = "@AffineOfficial"
$tags = "#affine #cloud"

# extract latest version and release
$tag = (Invoke-WebRequest "https://api.github.com/repos/m1911star/affine-client/releases/latest" | ConvertFrom-Json)[0].name
$tag = $tag.Trim("Affine Client v")
$release = (Invoke-WebRequest "https://api.github.com/repos/m1911star/affine-client/releases/latest" | ConvertFrom-Json)[0].body

$affinetag = (Invoke-WebRequest "https://api.github.com/repos/toeverything/AFFiNE/tags" | ConvertFrom-Json)[0].name
$affinetag = $affinetag.Trim("v")

$description = "
Affine is the next-generation collaborative knowledge base for professionals. There can be more than Notion and Miro. Affine is a next-gen knowledge base that brings planning, sorting and creating all together. Privacy first, open-source, customizable and ready to use. 
	
**The Affine project is still in development (so it is not recommended to use it in production), the current version is: $affinetag**

**32 bit users**: This package is not available for 32 bit users.

**Please Note**: This is an automatically updated package. If you find it is out of date by more than a day or two, please contact the maintainer(s) and let them know the package is no longer updating correctly.
"

# write new version and release
$file = "./$id/$id.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.package.metadata.description = $description
$xml.Save($file)

# download installer and LICENSE
Invoke-WebRequest -Uri "https://github.com/m1911star/affine-client/releases/download/affine-client-v$tag/Affine_0.1.0_x64_en-US.msi" -OutFile "./$id/tools/$id.msi"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/m1911star/affine-client/main/LICENSE" -OutFile "./$id/legal/LICENSE.txt"

# calculation of checksum
$TABLE = Get-FileHash "./$id/tools/$id.msi" -Algorithm SHA256
$SHA = $TABLE.Hash

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official github repository listed on <https://github.com/FilenCloudDienste/filen-desktop/releases>
and can be verified like this:

1. Download the following installer:
  Version $tag : <https://github.com/m1911star/affine-client/releases/download/affine-client-v$tag/Affine_$tag_x64_en-US.msi>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum: $SHA

File 'LICENSE.txt' is obtained from <https://raw.githubusercontent.com/m1911star/affine-client/main/LICENSE> " | out-file -filepath "./$id/legal/VERIFICATION.txt"

# packaging
choco pack "./$id/$id.nuspec" --outputdirectory ".\$id"

If ($LastExitCode -eq 0) {
	choco push "./$id/$id.$tag.nupkg" --source https://push.chocolatey.org/
	./END.ps1
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}