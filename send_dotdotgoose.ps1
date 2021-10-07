Invoke-WebRequest -Uri "https://biodiversityinformatics.amnh.org/open_source/dotdotgoose/" -OutFile "DDG.html"
Invoke-WebRequest -Uri "https://biodiversityinformatics.amnh.org/open_source/dotdotgoose/" -OutFile "release.html"
$Source = Get-Content -path DDG.html
$text = Get-Content -path release.html
$Source -match '<ul class="local-list"> <li>[0-9]{4}-[0-9]{2}-[0-9]{2} - version ([0-9]+(\.[0-9]+)+) '
$tag = $matches[1]

$pattern = '<ul class="local-list"> <li>(.*?)</li> </ul> </li>'
$result = [regex]::match($text, $pattern).Groups[1].Value

$release = $result -replace ' <ul class="local-list"> <li>', "`n* "
$release = $release -replace '</li> <li>', "`n* "
$release = $release -replace '(Enhancement)', '**Enhancement**'
$release = $release -replace '(Bug Fix)', '**Bug Fix**'
$release = $release -replace '(Bug Fixed)', '**Bug Fixed**'
$release = -join($release, "`n`n**Full changelog:** [https://biodiversityinformatics.amnh.org/open_source/dotdotgoose/](https://biodiversityinformatics.amnh.org/open_source/dotdotgoose/) ");


$file = "./dotdotgoose/dotdotgoose.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://biodiversityinformatics.amnh.org/open_source/dotdotgoose/ddg.php?op=download-win" -OutFile "dotdotgoose.zip"

Expand-Archive dotdotgoose.zip -DestinationPath .\dotdotgoose\tools\ -Force

Remove-Item dotdotgoose.zip

choco pack ./dotdotgoose/dotdotgoose.nuspec --outputdirectory .\dotdotgoose

If ($LastExitCode -eq 0) {
	choco push ./dotdotgoose/dotdotgoose.$tag.nupkg --source https://push.chocolatey.org/
} else {
 'Error - Exit code: $LastExitCode'
}
