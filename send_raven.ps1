# variables
$id = "raven"
$name = "Raven Reader"
$accounts = "@helloefficiency @mrgodhani"
$tags = "#raven"

# extract latest version and release
$tag = (Invoke-WebRequest "https://api.github.com/repos/hello-efficiency-inc/raven-reader/releases/latest" -Headers $headers | ConvertFrom-Json)[0].name
$tag = $tag.Trim("v")
$release = (Invoke-WebRequest "https://api.github.com/repos/hello-efficiency-inc/raven-reader/releases/latest" -Headers $headers | ConvertFrom-Json)[0].body

# $regex = '([0-9]{3,})'
# $release = $release -replace $regex, '[${1}](https://github.com/hello-efficiency-inc/raven-reader/issues/${1})'

# write new version and release
$file = "./$id/$id.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

# download installer and LICENSE
Invoke-WebRequest -Uri "https://github.com/hello-efficiency-inc/raven-reader/releases/download/v$tag/Raven-Reader-Setup-$tag.exe" -OutFile "./$id/tools/$id.exe"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/hello-efficiency-inc/raven-reader/master/LICENSE" -OutFile "./$id/legal/LICENSE.txt"

# calculation of checksum
$TABLE = Get-FileHash "./$id/tools/$id.exe" -Algorithm SHA256
$SHA = $TABLE.Hash

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official github repository listed on <https://github.com/hello-efficiency-inc/raven-reader/releases/>
and can be verified like this:

1. Download the following installer:
  Version $tag : <https://github.com/hello-efficiency-inc/raven-reader/releases/download/v$tag/Raven-Reader-Setup-$tag.exe>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum: $SHA

File 'LICENSE.txt' is obtained from <https://raw.githubusercontent.com/hello-efficiency-inc/raven-reader/master/LICENSE> " | out-file -filepath "./$id/legal/VERIFICATION.txt"

# packaging
choco pack "./$id/$id.nuspec" --outputdirectory ".\$id"


If ($LastExitCode -eq 0) {
	choco push "./$id/$id.$tag.nupkg" --source https://push.chocolatey.org/
	./END.ps1
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}