# Automatic update of Chocolatey packages

Github is the perfect Git repository to manage:

1. the source repository for chocolatey packages
2. regular checking of packages updates
3. automatic sending of packages to chocolatey as needed

---

Here are deposited:

* the script (*.ps1*) for making the package + sending
* the folder containing the files needed to manufacture the package
* the scripts (*.yml*) of github actions allowing the regular checking of updates and the launching of the scripts of packaging/sending

---

✔ It is possible to **directly download the .nupkg packages** from the [releases](https://github.com/A-d-r-i/update_choco_package/releases) if needed! Of course it is always better to install the packages from chocolatey (the packages are tested and verified).

---
| Name | Cycle | Automatic version | Automatic changelog | Official link | Chocolatey link |
|:---:|:---:|:---:|:---:|:---:|:---:|
|**Audiomoth Config App**|every 6 hours at minute 0|✅|✅|[Link](https://www.openacousticdevices.info/applications)|[Link](https://community.chocolatey.org/packages/audiomoth-config)|
|**Audiomoth USB Microphone App**|every 6 hours at minute 5|✅|✅|[Link](https://www.openacousticdevices.info/applications)|[Link](https://community.chocolatey.org/packages/audiomoth-usb)|
|**Audiomoth Flash App**|every 6 hours at minute 10|✅|✅|[Link](https://www.openacousticdevices.info/applications)|[Link](https://community.chocolatey.org/packages/audiomoth-flash)|
|**Audiomoth Time App**|every 6 hours at minute 15|✅|✅|[Link](https://www.openacousticdevices.info/applications)|[Link](https://community.chocolatey.org/packages/audiomoth-time)|
|**L0phtCrack**|every 6 hours at minute 20|✅|✅|[Link](https://l0phtcrack.gitlab.io/)|[Link](https://community.chocolatey.org/packages/l0phtcrack)|
|**HomeBank**|every 6 hours at minute 25|✅|✅|[Link](homebank.free.fr)|[Link](https://community.chocolatey.org/packages/homebank)|
|**Mendeley Reference Manager**|every 6 hours at minute 30|✅|✅|[Link](https://www.mendeley.com/reference-management/reference-manager)|[Link](https://community.chocolatey.org/packages/mendeley-reference-manager)|
|**FluffyChat**|every 6 hours at minute 32|✅|✅|[Link](https://fluffychat.im/)|[Link](https://community.chocolatey.org/packages/fluffychat)|
|**CTemplar**|every 6 hours at minute 35|✅|✅|[Link](https://ctemplar.com)|[Link](https://community.chocolatey.org/packages/ctemplar)|
|**Raven Reader**|every 6 hours at minute 40|✅|✅|[Link](https://ravenreader.app)|[Link](https://community.chocolatey.org/packages/raven)|
|**Sengi**|every 6 hours at minute 45|✅|✅|[Link](https://nicolasconstant.github.io/sengi)|[Link](https://community.chocolatey.org/packages/sengi)|
|**Tartube**|every 6 hours at minute 50|✅|✅|[Link](https://tartube.sourceforge.io)|[Link](https://community.chocolatey.org/packages/tartube)|
|**Open Video Downloader**|every 6 hours at minute 52|✅|✅|[Link](https://jely2002.github.io/youtube-dl-gui/)|[Link](https://community.chocolatey.org/packages/open-video-downloader)|
|**Dot Browser** (*Alpha*)|every 6 hours at minute 55|✅|✅|[Link](https://www.dothq.co/)|[Link](https://community.chocolatey.org/packages/dotbrowser)|
|**Tutanota**|every 6 hours at minute 59|✅|✅|[Link](https://tutanota.com)|[Link](https://community.chocolatey.org/packages/tutanota)|
|**Tenacity Audio Editor**|Manually [^1]|❌|❌|[Link](https://tenacityaudio.org)|[Link](https://community.chocolatey.org/packages/tenacity)|
|**DotDotGoose**|Manually [^2]|❌|❌|[Link](https://biodiversityinformatics.amnh.org/open_source/dotdotgoose/)|[Link](https://community.chocolatey.org/packages/dotdotgoose)|

[^1]: *Tenacity is still under development without release. So the update must be done manually.*  
[^2]: *DotDotGoose - [Issue 10](https://github.com/A-d-r-i/update_choco_package/issues/10)*

![update_choco_packages-3](https://user-images.githubusercontent.com/27277698/134149155-45a89285-542a-4bc8-a9d3-83ce57dc5fe9.png)
