# extract latest version and release
$tag = (Invoke-WebRequest "https://api.github.com/repos/m1911star/affine-client/releases/latest" | ConvertFrom-Json)[0].name
$tag = $tag -replace 'Affine Client v'
$release = (Invoke-WebRequest "https://api.github.com/repos/m1911star/affine-client/releases/latest" | ConvertFrom-Json)[0].body

$affinetag = (Invoke-WebRequest "https://api.github.com/repos/toeverything/AFFiNE/tags" | ConvertFrom-Json)[0].name
$affinetag = $affinetag -replace 'v'

$description = "
Affine is the next-generation collaborative knowledge base for professionals. There can be more than Notion and Miro. Affine is a next-gen knowledge base that brings planning, sorting and creating all together. Privacy first, open-source, customizable and ready to use. 
	
**The Affine project is still in development (so it is not recommended to use it in production), the current version is: $affinetag**

**32 bit users**: This package is not available for 32 bit users.

**Please Note**: This is an automatically updated package. If you find it is out of date by more than a day or two, please contact the maintainer(s) and let them know the package is no longer updating correctly.
"

# write new version and release
$file = "./affine-client/affine-client.nuspec"
$xml = New-Object XML
$xml.Load($file)
$xml.package.metadata.version = $tag
$xml.package.metadata.releaseNotes = $release
$xml.package.metadata.description = $description
$xml.Save($file)

# download installer and LICENSE
Invoke-WebRequest -Uri "https://github.com/m1911star/affine-client/releases/download/affine-client-v$tag/Affine_0.1.0_x64_en-US.msi" -OutFile "./affine-client/tools/affine-client.msi"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/m1911star/affine-client/main/LICENSE" -OutFile "./affine-client/legal/LICENSE.txt"

# calculation of checksum
$TABLE = Get-FileHash "./affine-client/tools/affine-client.msi" -Algorithm SHA256
$SHA = $TABLE.Hash

# writing of VERIFICATION.txt
$content = "VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

The installer have been downloaded from their official github repository listed on <https://github.com/FilenCloudDienste/filen-desktop/releases>
and can be verified like this:

1. Download the following installer:
  Version $tag : <https://github.com/m1911star/affine-client/releases/download/affine-client-v$tag/Affine_$tag_x64_en-US.msi>
2. You can use one of the following methods to obtain the checksum
  - Use powershell function 'Get-Filehash'
  - Use chocolatey utility 'checksum.exe'

  checksum type: SHA256
  checksum: $SHA

File 'LICENSE.txt' is obtained from <https://raw.githubusercontent.com/m1911star/affine-client/main/LICENSE> " | out-file -filepath ./affine-client/legal/VERIFICATION.txt

# packaging
choco pack ./affine-client/affine-client.nuspec --outputdirectory .\affine-client

If ($LastExitCode -eq 0) {
	choco push ./affine-client/affine-client.$tag.nupkg --source https://push.chocolatey.org/
} else {
	echo "Error in introduction - Exit code: $LastExitCode "
}

If ($LastExitCode -eq 0) {

# git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - affine-client" --allow-empty
git tag -a affine-client-v$tag -m "Affine-client- version $tag"
git push -f && git push --tags

# create release
Install-Module -Name New-GitHubRelease -Force
Import-Module -Name New-GitHubRelease
$newGitHubReleaseParameters = @{
GitHubUsername = "A-d-r-i"
GitHubRepositoryName = "update_choco_package"
GitHubAccessToken = "$env:ACTIONS_TOKEN"
ReleaseName = "Affine-client v$tag"
TagName = "affine-client-v$tag"
ReleaseNotes = "$release"
AssetFilePaths = ".\affine-client\affine-client.$tag.nupkg"
IsPreRelease = $false
IsDraft = $false
}
$resultrelease = New-GitHubRelease @newGitHubReleaseParameters

# post tweet
$twitter = (Select-String -Path config.txt -Pattern "twitter=(.*)").Matches.Groups[1].Value
if ( $twitter -eq "y" )
{
Install-Module PSTwitterAPI -Force
Import-Module PSTwitterAPI
$OAuthSettings = @{
ApiKey = "$env:PST_KEY"
ApiSecret = "$env:PST_SECRET"
AccessToken = "$env:PST_TOKEN"
AccessTokenSecret = "$env:PST_TOKEN_SECRET"
}
Set-TwitterOAuthSettings @OAuthSettings
Send-TwitterStatuses_Update -status "Affine-client v$tag push now on @chocolateynuget! 

Link: https://community.chocolatey.org/packages/affine-client/$tag
@AffineOfficial
#affine #cloud #release #opensource
"
}

# send telegram notification
Function Send-Telegram {
Param([Parameter(Mandatory=$true)][String]$Message)
$Telegramtoken = "$env:TELEGRAM"
$Telegramchatid = "$env:CHAT_ID"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($Telegramtoken)/sendMessage?chat_id=$($Telegramchatid)&text=$($Message)"}

Send-Telegram -Message "[UCP] New update of Affine-client : $tag"

} else {
	echo "Error in choco push - Exit code: $LastExitCode "
}
