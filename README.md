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
| Name | Cycle | Automatic version | Automatic changelog |
|:---:|:---:|:---:|:---:|
|**Audiomoth Config App**|every 6 hours at minute 0|✅|✅|
|**Audiomoth Flash App**|every 6 hours at minute 10|✅|✅|
|**Audiomoth Time App**|every 6 hours at minute 20|✅|✅|
|**Homebank**|every 6 hours at minute 25|✅|✅|
|**Mendeley Reference Manager**|every 6 hours at minute 30|✅|❌|
|**Raven**|every 6 hours at minute 40|✅|✅|
|**Tartube**|every 6 hours at minute 50|✅|✅|
|**Tutanota**|every 6 hours at minute 59|✅|✅|

![mermaid-diagram-20210915093027](https://user-images.githubusercontent.com/27277698/133391187-4cbc5c76-dc69-448a-b6b9-679015dab417.png)
