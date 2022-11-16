# variables
$id = "tartube"
$name = "Tartube"
$accounts = ""
$tags = "#tartube"

# extract latest version and release
$tag = (Invoke-WebRequest "https://api.github.com/repos/axcore/tartube/releases/latest" | ConvertFrom-Json)[0].tag_name
$tag = $tag.Trim("v")
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/axcore/tartube/master/CHANGES" -OutFile "release.txt"
$text = Get-Content -path release.txt

$pattern = '-------------------------------------------------------------------------------(.*?)v([0-9]+(\.[0-9]+)+)'
$result = [regex]::match($text, $pattern).Groups[1].Value

$release = $result -replace ' - ', "`n- "
$release = $release -replace '     ', ' '
$release = $release -replace '  ', "`n# "
$regex = '([0-9]{3,})'
$release = $release -replace $regex, '[${1}](https://github.com/axcore/tartube/issues/${1})'
$release = -join($release, "`n**Full changelog:** [https://raw.githubusercontent.com/axcore/tartube/master/CHANGES](https://raw.githubusercontent.com/axcore/tartube/master/CHANGES)");

# write new version and release
$file = "./$id/$id.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

# download installer and LICENSE
Invoke-WebRequest -Uri "https://github.com/axcore/tartube/releases/download/v$tag/install-tartube-$tag-64bit.exe" -OutFile "./$id/tools/$id.exe"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/axcore/tartube/master/LICENSE" -OutFile "./$id/legal/LICENSE.txt"

Remove-Item release.txt

# calculation of checksum
$TABLE64 = Get-FileHash "./$id/tools/$id.exe" -Algorithm SHA256
$SHA64 = $TABLE64.Hash

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official gitlab repository listed on <https://github.com/axcore/tartube/releases/>
and can be verified like this:

1. Download the following installer:
  Version $tag 64 bits : <https://github.com/axcore/tartube/releases/download/v$tag/install-tartube-$tag-64bit.exe>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum 64 bits: $SHA64

File 'LICENSE.txt' is obtained from <https://raw.githubusercontent.com/axcore/tartube/master/LICENSE> " | out-file -filepath "./$id/legal/VERIFICATION.txt"

# packaging
choco pack "./$id/$id.nuspec" --outputdirectory ".\$id"

If ($LastExitCode -eq 0) {
	choco push "./$id/$id.$tag.nupkg" --source https://push.chocolatey.org/
	./END.ps1
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}