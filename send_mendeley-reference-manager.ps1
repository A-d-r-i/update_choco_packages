# variables
$id = "mendeley-reference-manager"
$name = "Mendeley-Reference-Manager"
$accounts = "@mendeley_com @MendeleyApp @MendeleyTips"
$tags = "#mendeley"

# extract latest version and release
Invoke-WebRequest -Uri "https://www.mendeley.com/release-notes-reference-manager/" -OutFile "MRM.html"
$Source = Get-Content -path MRM.html -raw
$Source -match 'https://static.mendeley.com/md-stitch/releases/live/release-notes-reference-manager.([a-z\d]*).js'
$Sourceurl = $matches[1]

Invoke-WebRequest -Uri "https://static.mendeley.com/md-stitch/releases/live/release-notes-reference-manager.$Sourceurl.js" -OutFile "MRM.txt"
$Source = Get-Content -path MRM.txt -raw
$Source -match 'page:new URL\([a-z]\),path:"/v([0-9]+(\.[0-9]+)+)"'
$tag = $matches[1]

# release notes
$Sourcerelease = Get-Content -path MRM.txt -raw
$Sourcerelease -match 'path:"/v([0-9]+(\.[0-9]+)+)"'
$path = $matches[1]
$Sourcerelease -match "([0-9]+)_v$path.([a-zA-Z0-9]+).html"
$daterelease = $matches[1]
$daterelease = -join($daterelease, "_v");
$idrelease = $matches[2]
$URLrelease = "https://static.mendeley.com/md-stitch/releases/live/$daterelease$path.$idrelease.html"

Install-Module -Name MarkdownPrince -Force
Invoke-WebRequest -Uri "$URLrelease" -OutFile "MRM.html"
ConvertFrom-HTMLToMarkdown -Path "MRM.html" -UnknownTags Drop -GithubFlavored -DestinationPath "MRM.md"
$release = Get-Content -path MRM.md -raw
$release = -join($release, "`n`n**Full changelog:** [https://www.mendeley.com/release-notes-reference-manager/v$tag](https://www.mendeley.com/release-notes-reference-manager/v$path) ");

Remove-Item MRM.txt
Remove-Item MRM.html
Remove-Item MRM.md

# write new version and release
$file = "./$id/$id.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

# download installer
Invoke-WebRequest -Uri "https://static.mendeley.com/bin/desktop/mendeley-reference-manager-$tag-x64.exe" -OutFile "./$id/tools/$id.exe"

# calculation of checksum
$TABLE = Get-FileHash "./$id/tools/$id.exe" -Algorithm SHA256
$SHA = $TABLE.Hash

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official site repository listed on <https://www.mendeley.com/release-notes-reference-manager/>
and can be verified like this:

1. Download the following installer:
  Version $tag : <https://static.mendeley.com/bin/desktop/mendeley-reference-manager-$tag.exe>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum: $SHA

File 'LICENSE.txt' is obtained from the official website " | out-file -filepath "./$id/legal/VERIFICATION.txt"

# packaging
choco pack "./$id/$id.nuspec" --outputdirectory .\$id

If ($LastExitCode -eq 0) {
	choco push "./$id/$id.$tag.nupkg" --source https://push.chocolatey.org/
	./END.ps1
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}
