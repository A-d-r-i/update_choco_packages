$Version = ([xml](Get-Content ./tutanota/tutanota.nuspec)).package.metadata.version
$tag = (Invoke-WebRequest "https://api.github.com/repos/tutao/tutanota/releases/latest" | ConvertFrom-Json)[0].name

echo $Version
echo $tag

Start-Sleep -Seconds 5

if ( $tag -eq $Version )
{
echo 'Last version already exist'
}
else
{
$file = "./tutanota/tutanota.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.Save($file)

Invoke-WebRequest -Uri "https://mail.tutanota.com/desktop/tutanota-desktop-win.exe" -OutFile "./tutanota/tools/tutanota-desktop-win.exe"


choco pack ./tutanota/tutanota.nuspec --outputdirectory .\tutanota



If ($LastExitCode -eq 0) {
	choco push ./tutanota/tutanota.$tag.nupkg --source https://push.chocolatey.org/
} else {
 'Error'
}

}

Start-Sleep -Seconds 10