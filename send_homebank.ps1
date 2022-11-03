# variables
$id = "homebank"
$name = "HomeBank"
$accounts = ""
$tags = "#homebank"

# extract latest version and release
Invoke-WebRequest -Uri "http://homebank.free.fr/en/downloads.php" -OutFile "HOMEBANK.html"
Invoke-WebRequest -Uri "http://homebank.free.fr/ChangeLog" -OutFile "release.txt"
$Source = Get-Content -path HOMEBANK.html -raw
$text = Get-Content -path release.txt
$Source -match 'The latest <b>([0-9]+(\.[0-9]+)+) stable</b>'
$tag = $matches[1]


$search = "[0-9]{4}-[0-9]{2}-[0-9]{2}  Maxime Doyen"
$pattern = "$search(.*?)$search"
$result = [regex]::Match($text,$pattern).Groups[1].Value
$release = $result -replace '   :', ':'
$release = $release -replace '  :', ':'
$release = $release -replace '   *', "`n"
$release = $release -replace '  ', "`n"
$regex = '([0-9]{7,})'
$release = $release -replace $regex, '[${1}](https://bugs.launchpad.net/bugs/${1})'
$release = -join($release, "`n**Full changelog:** [http://homebank.free.fr/ChangeLog](http://homebank.free.fr/ChangeLog)");

# write new version and release
$file = "./$id/$id.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

# download installer
Invoke-WebRequest -Uri "http://homebank.free.fr/public/HomeBank-$tag-setup.exe" -OutFile "./$id/tools/$id.exe"

Remove-Item release.txt

# calculation of checksum
$TABLE = Get-FileHash "./$id/tools/$id.exe" -Algorithm SHA256
$SHA = $TABLE.Hash

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official site repository listed on <http://homebank.free.fr/fr/downloads.php>
and can be verified like this:

1. Download the following installer:
  Version $tag : <http://homebank.free.fr/public/HomeBank-$tag-setup.exe>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum: $SHA

File 'LICENSE.txt' is obtained from the official website " | out-file -filepath "./$id/legal/VERIFICATION.txt"

# packaging
choco pack "./$id/$id.nuspec" --outputdirectory ".\$id"

If ($LastExitCode -eq 0) {
	choco push "./$id/$id.$tag.nupkg" --source https://push.chocolatey.org/
	./END.ps1
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}