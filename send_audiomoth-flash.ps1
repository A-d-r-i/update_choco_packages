$tag = (Invoke-WebRequest "https://api.github.com/repos/OpenAcousticDevices/AudioMoth-Flash-App/releases/latest" | ConvertFrom-Json)[0].name
$release = (Invoke-WebRequest "https://api.github.com/repos/OpenAcousticDevices/AudioMoth-Flash-App/releases/latest" | ConvertFrom-Json)[0].body

$file = "./audiomoth-flash/audiomoth-flash.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://github.com/OpenAcousticDevices/AudioMoth-Flash-App/releases/download/$tag/AudioMothFlashAppSetup$tag.exe" -OutFile "./audiomoth-flash/tools/AudioMothFlashAppSetup.exe"

choco pack ./audiomoth-flash/audiomoth-flash.nuspec --outputdirectory .\audiomoth-flash

If ($LastExitCode -eq 0) {
	choco push ./audiomoth-flash/audiomoth-flash.$tag.nupkg --source https://push.chocolatey.org/
} else {
 'Error'
}

Start-Sleep -Seconds 10
