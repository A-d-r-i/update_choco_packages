# variables
$id = "tutanota"
$name = "Tutanota"
$accounts = "@TutanotaTeam"
$tags = "#tutanota"

# extract latest version and release
#$tag = (Invoke-WebRequest "https://api.github.com/repos/tutao/tutanota/releases/latest" -Headers $headers | ConvertFrom-Json)[0].name
#$release = (Invoke-WebRequest "https://api.github.com/repos/tutao/tutanota/releases/latest" -Headers $headers | ConvertFrom-Json)[0].body

$tag_releases = (Invoke-WebRequest "https://api.github.com/repos/tutao/tutanota/releases" -Headers $headers | ConvertFrom-Json) | where { $_.name -Match "[0-9]+\.[0-9]+\.[0-9]+ \(Desktop\)" }

$tag = $tag_releases[0].name
$tag = $tag -replace ' \(Desktop\)'

$release = $tag_releases[0].body

$regex = '#([0-9]{4,})'
$release = $release -replace $regex, '[#${1}](https://github.com/tutao/tutanota/issues/${1})'

# write new version and release
$file = "./$id/$id.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

# download installer and LICENSE
Invoke-WebRequest -Uri "https://github.com/tutao/tutanota/releases/download/tutanota-desktop-release-$tag/tutanota-desktop-win.exe" -OutFile "./$id/tools/$id.exe"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tutao/tutanota/master/LICENSE.txt" -OutFile "./$id/legal/LICENSE.txt"

# calculation of checksum
$TABLE = Get-FileHash "./$id/tools/$id.exe" -Algorithm SHA256
$SHA = $TABLE.Hash

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official github repository listed on <https://github.com/tutao/tutanota/releases/>
and can be verified like this:

1. Download the following installer:
  Version $tag : <https://github.com/tutao/tutanota/releases/download/tutanota-desktop-release-$tag/tutanota-desktop-win.exe>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum: $SHA

File 'LICENSE.txt' is obtained from <https://raw.githubusercontent.com/tutao/tutanota/master/LICENSE.txt> " | out-file -filepath "./$id/legal/VERIFICATION.txt"

# packaging
choco pack "./$id/$id.nuspec" --outputdirectory ".\$id"

If ($LastExitCode -eq 0) {
	choco push "./$id/$id.$tag.nupkg" --source https://push.chocolatey.org/
	./END.ps1
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}