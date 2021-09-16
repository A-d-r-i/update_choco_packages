$tag = (Invoke-WebRequest "https://api.github.com/repos/OpenAcousticDevices/AudioMoth-Configuration-App/releases/latest" | ConvertFrom-Json)[0].name
$release = (Invoke-WebRequest "https://api.github.com/repos/OpenAcousticDevices/AudioMoth-Configuration-App/releases/latest" | ConvertFrom-Json)[0].body

$file = "./audiomoth-config/audiomoth-config.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.Save($file)

Invoke-WebRequest -Uri "https://github.com/OpenAcousticDevices/AudioMoth-Configuration-App/releases/download/$tag/AudioMothConfigurationAppSetup$tag.exe" -OutFile "./audiomoth-config/tools/AudioMothConfigurationAppSetup.exe"

choco pack ./audiomoth-config/audiomoth-config.nuspec --outputdirectory .\audiomoth-config

If ($LastExitCode -eq 0) {
	choco push ./audiomoth-config/audiomoth-config.$tag.nupkg --source https://push.chocolatey.org/
} else {
 'Error'
}

Start-Sleep -Seconds 10
