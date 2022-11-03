# variables
$id = "dotdotgoose"
$name = "DotDotGoose"
$accounts = ""
$tags = "#dotdotgoose"

# extract latest version and release

Invoke-WebRequest -Uri "https://biodiversityinformatics.amnh.org/open_source/dotdotgoose/index.html" -OutFile "DDG.html"
Invoke-WebRequest -Uri "https://biodiversityinformatics.amnh.org/open_source/dotdotgoose/index.html" -OutFile "release.html"
$Source = Get-Content -path DDG.html
$text = Get-Content -path release.html
$Source -match '<ul class="local-list"> <li>[0-9]{4}-[0-9]{2}-[0-9]{2} - version ([0-9]+(\.[0-9]+)+) '
$tag = $matches[1]

# $tag = "1.5.3"

$pattern = '<ul class="local-list"> <li>(.*?)</li> </ul> </li>'
$result = [regex]::match($text, $pattern).Groups[1].Value

$release = $result -replace ' <ul class="local-list"> <li>', "`n* "
$release = $release -replace '</li> <li>', "`n* "
$release = $release -replace '\(Enhancement\)', '**Enhancement** -'
$release = $release -replace '\(Bug Fix\)', '**Bug Fix** -'
$release = $release -replace '\(Bug Fixed\)', '**Bug Fixed** -'
$release = -join($release, "`n`n**Full changelog:** [https://biodiversityinformatics.amnh.org/open_source/dotdotgoose/](https://biodiversityinformatics.amnh.org/open_source/dotdotgoose/) ");

# write new version and release
$file = "./$id/$id.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = "$release"# https://biodiversityinformatics.amnh.org/open_source/dotdotgoose/ " # $release
$xml.Save($file)

# download installer and LICENSE
Invoke-WebRequest -Uri "https://biodiversityinformatics.amnh.org/open_source/dotdotgoose/ddg.php?op=download-win" -OutFile "dotdotgoose.zip"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/persts/DotDotGoose/master/LICENSE" -OutFile "./$id/legal/LICENSE.txt"

Expand-Archive "dotdotgoose.zip" -DestinationPath ".\$id\tools\" -Force

Remove-Item dotdotgoose.zip

# calculation of checksum
$TABLE = Get-FileHash "./$id/tools/DotDotGoose.exe" -Algorithm SHA256
$SHA = $TABLE.Hash

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official website listed on <https://biodiversityinformatics.amnh.org/open_source/dotdotgoose/ddg.php?op=download-win>
and can be verified like this:

1. Download the following installer:
  Version $tag : <https://biodiversityinformatics.amnh.org/open_source/dotdotgoose/ddg.php?op=download-win>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum: $SHA

File 'LICENSE.txt' is obtained from <https://raw.githubusercontent.com/persts/DotDotGoose/master/LICENSE> " | out-file -filepath "./$id/legal/VERIFICATION.txt"

# packaging
choco pack "./$id/$id.nuspec" --outputdirectory ".\$id"

If ($LastExitCode -eq 0) {
	choco push "./$id/$id.$tag.nupkg" --source https://push.chocolatey.org/
	./END.ps1
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}