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
## Process by package :

* **Audiomoth Config App** : check every 6 hours at minute 0
* **Audiomoth Flash App** : check every 6 hours at minute 10
* **Audiomoth Time App** : check every 6 hours at minute 20
* **Mendeley Reference Manager** : check every 6 hours at minute 30
* **Raven** : check every 6 hours at minute 40
* **Tartube** : check every 6 hours at minute 50
* **Tutanota** : check every 6 hours at minute 59
