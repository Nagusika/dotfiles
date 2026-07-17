# dotfiles

Environnement shell + terminal, **KISS et agnostique**. Un `git clone` + un script,
d'une machine vierge à un poste complet, à l'identique sur **Ubuntu/Debian,
AlmaLinux/RHEL, Arch et WSL**.

> 🚧 **Refonte en cours.** Le socle historique (i3/GlazeWM/p10k) a été archivé
> sous les tags `v0-legacy` et `legacy-endeavouros`. La nouvelle architecture se
> construit par étapes (voir *Feuille de route* en bas). Modules disponibles :
> **shell** + **prompt**. `./bootstrap.sh` installe zsh/starship et déploie les
> configs — il **remplace** `~/.bashrc`/`~/.zshrc` existants (backup horodaté
> automatique sous `~/.local/state/dotfiles/backup-*`). `chsh` vers zsh reste
> une action manuelle.

## Principes

- **Aucun config management** (pas d'Ansible, pas de chezmoi). Bash/POSIX pur.
- **Idempotent** : relançable à volonté, ne casse rien.
- **Dégradation gracieuse** : un outil absent du dépôt n'avorte pas le bootstrap.
- **Extensible par convention** : ajouter un outil = créer un dossier dans
  `modules/`, jamais toucher au moteur.
- **Une seule abstraction** du gestionnaire de paquets (`apt`/`dnf`/`pacman`).

## Architecture cible

```
bootstrap.sh      # point d'entrée unique
doctor.sh         # diagnostic idempotent
lib/              # le moteur : os / pkg / fetch / link (aucune connaissance d'un outil)
profiles/         # default (headless) | workstation (GUI)
modules/          # 1 outil = 1 dossier ; son home/ EST le manifeste de symlinks
vendor/           # plugins tiers, clonés+pinnés au bootstrap (gitignoré)
ci/               # bootstrap testé en conteneurs Ubuntu / AlmaLinux / Arch
```

Les outils modernes (eza, starship, zoxide, delta…) absents des dépôts RHEL/EPEL
sont récupérés en **binaires musl pinnés + checksum** dans `~/.local/bin`, pas via
le gestionnaire de paquets.

## Choix tranchés

| Sujet | Décision |
|---|---|
| Symlinks | Script maison (miroir `home/`), pas GNU Stow |
| Shell | zsh interactif + bash (fallback POSIX partagé), ble.sh sur workstation |
| Prompt | Starship, TOML sobre partagé bash+zsh |
| Plugins | Clone-au-bootstrap pinné, pas de submodules |
| Multiplexeur | tmux (distant) + splits kitty (local) |
| Éditeur | vimrc portable partout + nvim local |

## Feuille de route

- [x] **E0** — hygiène : archivage legacy, `.gitattributes`/`.gitignore`, encodage UTF-8/LF
- [x] **E1** — moteur `lib/` + `bootstrap.sh` + `doctor.sh` (inerte, testé en dry-run)
- [x] **E2** — modules shell + prompt (zsh/bash/ble.sh/starship, cœur POSIX partagé)
- [x] **E3** — modules cli + git (eza/fzf/zoxide/bat/fd/rg + delta, git aliases)
- [x] **E4** — modules kitty + fonts (config réécrite, Dainty Dark, JetBrainsMono NF)
- [x] **E5** — modules tmux + vim (tmux.conf sobre préfixe C-a, vimrc portable)
- [x] **E6** — CI conteneurs Ubuntu/AlmaLinux/Arch + shellcheck (portabilité **prouvée**)

Reste optionnel : module `nvim` (workstation, `à venir` dans le profil).

## Récupérer l'ancienne config

```sh
git show v0-legacy:zsh/.zshrc          # afficher un fichier archivé
git checkout v0-legacy -- i3/config    # restaurer un fichier de l'ancien socle
```

## Licence

[MIT](LICENSE).
