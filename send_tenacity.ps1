# variables
$id = "tenacity"
$name = "Tenacity"
$accounts = "@TenacityAudio"
$tags = "#tenacity"

# extract latest version and release
$json = (Invoke-WebRequest "https://codeberg.org/api/v1/repos/tenacityteam/tenacity/releases" | ConvertFrom-Json)[0]
$tag = $json.tag_name
if ($tag -match '^[0-9]+.[0-9]+$'){
	$tag = $tag + ".0"
}
$tag = $tag.Trim("v")
$release = $json.body

# write new version and release
$file = "./$id/$id.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

# download installer and LICENSE
$urltag = "v" + $tag
#$urltag = $urltag -replace "-beta",".0"
$url64 = ($json.assets | where { $_.name -eq "tenacity-win-$urltag-x86_64.exe" }).browser_download_url
$url32 = ($json.assets | where { $_.name -eq "tenacity-win-$urltag-x86.exe" }).browser_download_url

Invoke-WebRequest -Uri $url64 -OutFile ".\$id\tools\tenacity64.exe"
Invoke-WebRequest -Uri $url32 -OutFile ".\$id\tools\tenacity32.exe"

Invoke-WebRequest -Uri "https://codeberg.org/tenacityteam/tenacity/raw/branch/main/LICENSE.txt" -OutFile "./$id/legal/LICENSE.txt"

# calculation of checksum
$TABLE64 = Get-FileHash "./$id/tools/tenacity64.exe" -Algorithm SHA256
$SHA64 = $TABLE64.Hash

$TABLE32 = Get-FileHash "./$id/tools/tenacity32.exe" -Algorithm SHA256
$SHA32 = $TABLE32.Hash

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official github repository listed on <https://codeberg.org/tenacityteam/tenacity/releases>
and can be verified like this:

1. Download the following installer:
  Version $tag 64 bits : <https://codeberg.org/tenacityteam/tenacity/releases/tag/v$tag>
  Version $tag 32 bits : <https://codeberg.org/tenacityteam/tenacity/releases/tag/v$tag>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum 64 bits: $SHA64
  checksum 32 bits: $SHA32

File 'LICENSE.txt' is obtained from <https://codeberg.org/tenacityteam/tenacity/raw/branch/main/LICENSE.txt> " | out-file -filepath "./$id/legal/VERIFICATION.txt"

# packaging
choco pack "./$id/$id.nuspec" --outputdirectory ".\$id"

If ($LastExitCode -eq 0) {
	choco push "./$id/$id.$tag.nupkg" --source https://push.chocolatey.org/
	./END.ps1
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}
