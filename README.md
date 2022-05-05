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
|**Audiomoth Config App**|Every 2 hours|✅|✅|[Link](https://www.openacousticdevices.info/applications)|[Link](https://community.chocolatey.org/packages/audiomoth-config)|
|**Audiomoth USB Microphone App**|Every 2 hours|✅|✅|[Link](https://www.openacousticdevices.info/applications)|[Link](https://community.chocolatey.org/packages/audiomoth-usb)|
|**Audiomoth Flash App**|Every 2 hours|✅|✅|[Link](https://www.openacousticdevices.info/applications)|[Link](https://community.chocolatey.org/packages/audiomoth-flash)|
|**Audiomoth Time App**|Every 2 hours|✅|✅|[Link](https://www.openacousticdevices.info/applications)|[Link](https://community.chocolatey.org/packages/audiomoth-time)|
|**L0phtCrack**|Every 2 hours|✅|✅|[Link](https://l0phtcrack.gitlab.io/)|[Link](https://community.chocolatey.org/packages/l0phtcrack)|
|**HomeBank**|Every 2 hours|✅|✅|[Link](homebank.free.fr)|[Link](https://community.chocolatey.org/packages/homebank)|
|**Mendeley Reference Manager**|Every 2 hours|✅|✅|[Link](https://www.mendeley.com/reference-management/reference-manager)|[Link](https://community.chocolatey.org/packages/mendeley-reference-manager)|
|**FluffyChat**|Every 2 hours|✅|✅|[Link](https://fluffychat.im/)|[Link](https://community.chocolatey.org/packages/fluffychat)|
|**CTemplar**|Every 2 hours|✅|✅|[Link](https://ctemplar.com)|[Link](https://community.chocolatey.org/packages/ctemplar)|
|**Raven Reader**|Every 2 hours|✅|✅|[Link](https://ravenreader.app)|[Link](https://community.chocolatey.org/packages/raven)|
|**Sengi**|Every 2 hours|✅|✅|[Link](https://nicolasconstant.github.io/sengi)|[Link](https://community.chocolatey.org/packages/sengi)|
|**Tartube**|Every 2 hours|✅|✅|[Link](https://tartube.sourceforge.io)|[Link](https://community.chocolatey.org/packages/tartube)|
|**Open Video Downloader**|Every 2 hours|✅|✅|[Link](https://jely2002.github.io/youtube-dl-gui/)|[Link](https://community.chocolatey.org/packages/open-video-downloader)|
|**Dot Browser** (*Alpha*)|Every 2 hours|✅|✅|[Link](https://www.dothq.co/)|[Link](https://community.chocolatey.org/packages/dotbrowser)|
|**Tutanota**|Every 2 hours|✅|✅|[Link](https://tutanota.com)|[Link](https://community.chocolatey.org/packages/tutanota)|
|**DotDotGoose**|Every 2 hours & Manually [^1]|✅|✅|[Link](https://biodiversityinformatics.amnh.org/open_source/dotdotgoose/)|[Link](https://community.chocolatey.org/packages/dotdotgoose)|
|**Tenacity Audio Editor**|Manually [^2]|❌|❌|[Link](https://tenacityaudio.org)|[Link](https://community.chocolatey.org/packages/tenacity)|

[^1]: *DotDotGoose - [Issue 10](https://github.com/A-d-r-i/update_choco_package/issues/10)*  
[^2]: *Tenacity is still under development without release. So the update must be done manually.*

![update_choco_packages-3](https://user-images.githubusercontent.com/27277698/134149155-45a89285-542a-4bc8-a9d3-83ce57dc5fe9.png)
