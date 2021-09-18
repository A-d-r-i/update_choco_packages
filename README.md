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
| Name | Cycle | Automatic version | Automatic changelog | Official link | Chocolatey link |
|:---:|:---:|:---:|:---:|:---:|:---:|
|**Audiomoth Config App**|every 6 hours at minute 0|✅|✅|[Link](https://www.openacousticdevices.info/applications)|[Link](https://community.chocolatey.org/packages/audiomoth-config)|
|**Audiomoth Flash App**|every 6 hours at minute 10|✅|✅|[Link](https://www.openacousticdevices.info/applications)|[Link](https://community.chocolatey.org/packages/audiomoth-flash)|
|**Audiomoth Time App**|every 6 hours at minute 20|✅|✅|[Link](https://www.openacousticdevices.info/applications)|[Link](https://community.chocolatey.org/packages/audiomoth-time)|
|**Homebank**|every 6 hours at minute 25|✅|✅|[Link](homebank.free.fr)|[Link](https://community.chocolatey.org/packages/homebank)|
|**Mendeley Reference Manager**|every 6 hours at minute 30|✅|✅|[Link](https://www.mendeley.com/reference-management/reference-manager)|[Link](https://community.chocolatey.org/packages/mendeley-reference-manager)|
|**Raven**|every 6 hours at minute 40|✅|✅|[Link](https://ravenreader.app/)|[Link](https://community.chocolatey.org/packages/raven)|
|**Tartube**|every 6 hours at minute 50|✅|✅|[Link](https://tartube.sourceforge.io/)|[Link](https://community.chocolatey.org/packages/tartube)|
|**Tutanota**|every 6 hours at minute 59|✅|✅|[Link](https://tutanota.com/)|[Link](https://community.chocolatey.org/packages/tutanota)|

![mermaid-diagram-20210915093027](https://user-images.githubusercontent.com/27277698/133391187-4cbc5c76-dc69-448a-b6b9-679015dab417.png)
