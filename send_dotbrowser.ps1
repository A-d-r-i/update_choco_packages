# variables
$id = "dotbrowser"
$name = "DotBrowser"
$accounts = "@DotBrowser"
$tags = "#dotbrowser"

# extract latest version and release
$tag = (Invoke-WebRequest "https://api.github.com/repos/dothq/browser-desktop/releases/latest" -Headers $headers | ConvertFrom-Json)[0].tag_name
$release = (Invoke-WebRequest "https://api.github.com/repos/dothq/browser-desktop/releases/latest" -Headers $headers | ConvertFrom-Json)[0].body

$tagalpha = $tag -replace '([0-9]*\.[0-9]+)-([0-9]{4})-([0-9]{2})-([0-9]{2})', '$1.$2$3$4'
$tagalpha = -join($tagalpha,"-alpha");

# write new version and release
$file = "./$id/$id.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tagalpha
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

# download installer and LICENSE
Invoke-WebRequest -Uri "https://github.com/dothq/browser-desktop/releases/download/$tag/dot-87.0.exe" -OutFile "./$id/tools/$id.exe"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/dothq/browser-desktop/master/LICENSE" -OutFile "./$id/legal/LICENSE.txt"

# calculation of checksum
$TABLE = Get-FileHash "./$id/tools/$id.exe" -Algorithm SHA256
$SHA = $TABLE.Hash

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official github repository listed on <https://github.com/dothq/browser-desktop/releases/>
and can be verified like this:

1. Download the following installer:
  Version $tag : <https://github.com/dothq/browser-desktop/releases/download/$tag/dot-87.0.exe>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum: $SHA

File 'LICENSE.txt' is obtained from <https://raw.githubusercontent.com/dothq/browser-desktop/master/LICENSE> " | out-file -filepath "./$id/legal/VERIFICATION.txt"

# packaging
choco pack "./$id/$id.nuspec" --outputdirectory ".\$id"

If ($LastExitCode -eq 0) {
	choco push "./$id/$id.$tagalpha.nupkg" --source https://push.chocolatey.org/
	./END.ps1
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}