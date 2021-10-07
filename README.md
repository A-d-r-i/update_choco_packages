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
|**Audiomoth Flash App**|every 6 hours at minute 10|✅|✅|[Link](https://www.openacousticdevices.info/applications)|[Link](https://community.chocolatey.org/packages/audiomoth-flash)|
|**Audiomoth Time App**|every 6 hours at minute 20|✅|✅|[Link](https://www.openacousticdevices.info/applications)|[Link](https://community.chocolatey.org/packages/audiomoth-time)|
|**HomeBank**|every 6 hours at minute 25|✅|✅|[Link](homebank.free.fr)|[Link](https://community.chocolatey.org/packages/homebank)|
|**Mendeley Reference Manager**|every 6 hours at minute 30|✅|✅|[Link](https://www.mendeley.com/reference-management/reference-manager)|[Link](https://community.chocolatey.org/packages/mendeley-reference-manager)|
|**CTemplar**|every 6 hours at minute 35|✅|✅|[Link](https://ctemplar.com)|[Link](https://community.chocolatey.org/packages/ctemplar)|
|**Raven Reader**|every 6 hours at minute 40|✅|✅|[Link](https://ravenreader.app)|[Link](https://community.chocolatey.org/packages/raven)|
|**Sengi**|every 6 hours at minute 45|✅|✅|[Link](https://nicolasconstant.github.io/sengi)|[Link](https://community.chocolatey.org/packages/sengi)|
|**Tartube**|every 6 hours at minute 50|✅|✅|[Link](https://tartube.sourceforge.io)|[Link](https://community.chocolatey.org/packages/tartube)|
|**Tutanota**|every 6 hours at minute 59|✅|✅|[Link](https://tutanota.com)|[Link](https://community.chocolatey.org/packages/tutanota)|
|**Tenacity Audio Editor**|Manually \*|❌|❌|[Link](https://tenacityaudio.org)|[Link](https://community.chocolatey.org/packages/tenacity)|
|**DotDotGoose**|Manually|❌|❌|[Link](https://biodiversityinformatics.amnh.org/open_source/dotdotgoose/)|Still not on chocolatey ([#10](https://github.com/A-d-r-i/update_choco_package/issues/10))|

*\* Tenacity is still under development without release. So the update must be done manually.*

![update_choco_packages-3](https://user-images.githubusercontent.com/27277698/134149155-45a89285-542a-4bc8-a9d3-83ce57dc5fe9.png)
