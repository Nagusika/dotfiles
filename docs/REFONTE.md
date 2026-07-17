# Refonte — état, décisions, reprise

Document de suivi de la refonte des dotfiles. Sert aussi de point de reprise :
une session fraîche (après réinstallation machine) doit pouvoir `git clone` puis
continuer exactement d'ici. Voir aussi les messages de commit E0/E1 (détaillés).

## État d'avancement

- [x] **E0** — hygiène : legacy archivé (tags `v0-legacy`, `legacy-endeavouros`),
      `git rm` i3/.glzr/p10k/templates/starship/kitty-bak+symlinks-cassés/zsh-install.zsh,
      ajout `.gitattributes`(eol=lf)/`.gitignore`/`.editorconfig`/`LICENSE`,
      README réécrit UTF-8/LF. Commit `d2ae755` (poussé).
- [x] **E1** — moteur `lib/` + `bootstrap.sh` + `doctor.sh`, inerte, testé.
- [x] **E2** — modules `shell` + `prompt`. Cœur POSIX `common.sh`+aliases+functions
      partagé bash/zsh ; `.profile`/`.bash_profile`/`.zprofile`/`.bashrc`/`.zshrc` ;
      plugins zsh vendored (autosuggestions v0.7.1, syntax-highlighting 0.8.0) ;
      ble.sh v0.4.0-devel3 build workstation-only ; Starship 1.26.0 (musl pinné +
      checksum) + `starship.toml` sobre. Validé : install starship réel + checksum,
      linker réel, sourcing POSIX. `profiles/default` = shell prompt ; `workstation`
      = `@default`. **Prochaine étape : E3.**
- [x] **E3** — modules `cli` (bat/fd/ripgrep/fzf/btop tier-1 ; eza 0.23.5 + zoxide
      0.10.0 tier-2 musl ; shims batcat/fdfind→bat/fd pour Debian) + `git` (git +
      delta 0.19.2 tier-2 ; `~/.config/git/{config,ignore}`, aliases, identité via
      include `~/.config/dotfiles/git.local`). Validé : installs réels + checksums,
      identité git via include (`git var GIT_AUTHOR_IDENT`). **Prochaine : E4.**
- [x] **E4** — modules `kitty` (pkg kitty ; `kitty.conf` réécrit — plus de
      linux_display_server forcé, url_color OK, shell_integration enabled, splits +
      keybindings ; thème Dainty Dark ; includes) + `fonts` (JetBrainsMono Nerd Font
      v3.4.0 dans ~/.local/share/fonts, checksum, skip WSL). Validé : parse réel de
      kitty.conf (kitty 0.47 load_config, includes OK) ; install fonts réelle (48 ttf).
      `profiles/workstation` = @default kitty fonts. **Prochaine : E5.**
- [x] **E5** — modules `tmux` (préfixe C-a, splits vim, mouse, mode-copie vi, status
      sobre) + `vim` (`vim dnf:vim-enhanced` ; vimrc portable sans plugin, état
      regroupé sous ~/.local/state/vim). Validé : parse réel tmux 3.6a ; vimrc revu
      (vim absent de la machine → validé en CI E6). `profiles/default` complet.
- [x] **E6** — CI : `.github/workflows/ci.yml` (matrice ubuntu:24.04 / almalinux:10 /
      archlinux:latest via `docker run … sh ci/run.sh` + job shellcheck) et `ci/run.sh`
      (conteneur vierge → user non-root sudo → bootstrap default + doctor + lints
      bash/zsh/vim/dash). **Exécuté réellement en local via podman : les 3 distros
      passent (EXIT 0)**, doctor sain, lints OK, shellcheck propre. Correctifs au
      passage : `pacman -Sy` initial dans pkg.sh ; directives/exclusions shellcheck.

Reste optionnel : module `nvim` (workstation, init.lua ~150 l LSP light, install nvim
tier-2 par tarball — pas install_bin car nvim n'est pas un binaire unique).

NB : la machine de dev est passée d'AlmaLinux 10 à **Fedora 44** en cours de route
(preuve à l'usage de l'agnosticité : `os.sh` mappe `fedora`→`dnf`, rien à changer).

## Cible & contraintes

Machine de référence : **AlmaLinux 10.2 + EPEL + CRB**, `dnf`, login shell bash 5.2.
Objectif : `git clone` + `./bootstrap.sh` → env complet, identique sur
Ubuntu/Debian, AlmaLinux/RHEL, Arch, WSL. KISS, agnostique, aucun config
management, idempotent, lisible en 5 min.

Faits d'environnement vérifiés (importants pour E2+) :
- **Paquets ABSENTS des dépôts EL/EPEL** (à récupérer en binaire musl via
  `install_bin`, tier-2) : `starship`, `eza`, `zoxide`, `git-delta`, `lazygit`,
  `zellij`, `dust`, `direnv`, `atuin`, Nerd Fonts.
- **Paquets présents** (tier-1, `pkg_install`) : `zsh` 5.9, `kitty` 0.43, `bat`
  0.24, `fd-find` (bin `fd`), `ripgrep` (bin `rg`), `fzf` 0.58 (≥0.48 → `fzf --bash/--zsh`
  natifs), `btop`, `tmux` 3.3, `neovim` 0.10, `vim`, `just`, `jetbrains-mono-fonts`.
- Sur EL10 les binaires s'appellent déjà `fd`/`bat`/`rg` (le renommage
  `fdfind`/`batcat` est **spécifique Debian/Ubuntu** → géré par symlink dans `cli`).
- **`sudo` est interactif** sur la machine de dev (demande un mot de passe) → un
  agent ne peut pas installer de paquets sans l'utilisateur. Tester les modules
  en dry-run + HOME jetable ; l'install réelle des paquets est une action utilisateur.
- **Réseau HTTPS GitHub OK** (releases + raw) → les checksums des binaires tier-2
  peuvent être récupérés à la construction.
- **Push SSH GitHub** : nécessite la clé/agent de l'utilisateur (échoue en
  non-interactif). Les commits sont locaux tant que l'utilisateur ne pousse pas.

## Décisions verrouillées (font autorité)

| Sujet | Décision |
|---|---|
| Symlinks | Script maison (miroir `modules/<x>/home/`), **pas** GNU Stow |
| Shell | zsh interactif principal + bash fallback ; cœur `common.sh` POSIX strict partagé |
| ble.sh | **Workstation-only** (pas d'autosuggestions bash en SSH/éphémère — assumé) |
| Prompt | **Starship**, un seul TOML sobre (~60 l) partagé bash+zsh |
| Plugins | **Clone-au-bootstrap pinné** (`vendor.manifest`), pas de submodules, pas zinit |
| Multiplexeur | **tmux** (distant) + splits kitty (local) |
| Éditeur | **vimrc** portable partout + **nvim** local (init.lua ~150 l, LSP light, pas kickstart) |
| mise | **Différé P2** |
| atuin | **P2, sur Ctrl-R** ; widget fzf-history déplacé sur **Ctrl-T** |
| Login shell | `chsh` vers zsh = **action utilisateur finale**, jamais automatique |

## Contrat du moteur (comment ajouter un module — pour E2+)

Un module = un dossier `modules/<nom>/`. Le bootstrap applique, dans l'ordre :
1. `requires` (optionnel) : une dépendance par ligne → appliquée d'abord (dédup).
2. `packages` (optionnel) : lignes `nom [apt:x dnf:y pacman:z]` → `pkg_install`
   (override par famille ; ex. `fd apt:fd-find dnf:fd-find pacman:fd`).
3. `module.sh` (optionnel) : sourcé en sous-shell ; s'il définit `mod_install`,
   elle est appelée (pour `install_bin`, builds, stubs…). Un échec = warn, non fatal.
4. `home/` : **miroir de `$HOME`**. Chaque fichier est symlinké au grain feuille
   (jamais un répertoire). Idempotent, backup horodaté de tout vrai fichier écrasé.

Profils (`profiles/<nom>`) : liste de modules, un par ligne ; `@autre` inclut un
autre profil. `default` = headless ; `workstation` = `@default` + couche GUI.
Ajouter un module ne touche JAMAIS `bootstrap.sh` ni `lib/` — seulement créer le
dossier et l'ajouter au(x) profil(s).

Helpers dispo dans `module.sh` (via `lib/`) : `say/info/warn/die`, `run` (respecte
`DRY_RUN`), `PM/ARCH/IS_WSL/SUDO/NO_ROOT`, `pkg_install`, `install_bin <bin> <ver>
<url> <sha256>` (version-gate + **checksum fatal**), `vendor_sync`.

⚠ **Piège outillage** : l'outil d'édition d'agent **préserve l'encodage** d'un
fichier existant → un fichier UTF-16 réécrit reste UTF-16. Convertir explicitement
(`iconv -f UTF-16LE -t UTF-8`). C'est le bug qui avait touché le README en E0.

⚠ **Piège récursion** : dans les fonctions récursives, déclarer les variables
`local` (bug corrigé en E1 : `_dir` global écrasé par la récursion `requires`).

## Prochaine étape — E2 (plan détaillé)

Créer :
- `modules/shell/packages` : `zsh`, `bash-completion`, `make`, `gawk` (deps ble.sh).
- `modules/shell/module.sh` (`mod_install`) : sur `workstation` uniquement, build
  ble.sh depuis `vendor/ble.sh` (`make -C vendor/ble.sh install PREFIX=~/.local`) ;
  créer les stubs `~/.config/dotfiles/local.sh` (gitignoré côté HOME) et
  `~/.config/dotfiles/profile`.
- `modules/shell/home/.profile` : login POSIX, prepend `~/.local/bin` au PATH,
  source `common.sh`.
- `modules/shell/home/.bashrc` : garde interactive `[[ $- == *i* ]]`, source
  `common.sh`, readline, attache ble.sh **si présent** (workstation), init bash
  de starship/fzf/zoxide/atuin **si présents**.
- `modules/shell/home/.zshrc` : source `common.sh`, `compinit -C`, hist 50k,
  source des plugins vendored (`vendor/zsh-autosuggestions`, `vendor/zsh-syntax-highlighting`),
  init zsh de starship/fzf/zoxide/atuin **si présents**.
- `modules/shell/home/.config/sh/common.sh` : **POSIX strict** (valider
  `dash -n` + `shellcheck -s sh`), exports (EDITOR, PAGER…), source `aliases.sh`,
  `functions.sh`, puis `~/.config/dotfiles/local.sh` en dernier.
- `modules/shell/home/.config/sh/aliases.sh` : alias gardés par `command -v`
  (ex. `ls`→`eza` si présent, sinon `ls --color`). **Ne pas** refaire les bugs
  de l'ancien (`grep=rg`, `exa` EOL, `rg=ripgrep`).
- `modules/shell/home/.config/sh/functions.sh` : reprendre `extract`, `up`
  (réécrire POSIX), `ftext`, `cpg`, `mvg`, `mkcd`. Récupérables depuis
  `git show v0-legacy:bash/.bashrc`.
- `modules/prompt/module.sh` : `install_bin starship` (ou script officiel) → `~/.local/bin`.
- `modules/prompt/home/.config/starship.toml` : built-in only, ZÉRO module custom
  forkeur, 1 palette. (Ancien à ne PAS reprendre : `git show v0-legacy:starship/starship.toml`.)
- `vendor.manifest` : ajouter `vendor/zsh-autosuggestions` (v0.7.1),
  `vendor/zsh-syntax-highlighting` (0.8.0), `vendor/ble.sh` (SHA à pinner).
- `profiles/default` : ajouter `shell` puis `prompt`.

Ctrl-R/Ctrl-T : câbler la logique dans les rc pour que fzf prenne Ctrl-T et
laisse Ctrl-R à atuin **quand atuin sera présent** (P2), sinon fzf sur Ctrl-R.

Choix d'implémentation à trancher en E2/E3 : checksums tier-2 — soit pinner un
sha256 calculé dans `versions.env`/le module, soit vérifier contre le fichier
SHASUMS upstream récupéré au build. Réseau HTTPS dispo pour les deux.

Test de chaque étape : `HOME=$(mktemp -d) DRY_RUN=1 ./bootstrap.sh default` puis
inspection ; linker en réel sur HOME isolé ; jamais d'install paquet réelle sans
l'utilisateur (sudo interactif).

## Récupérer l'ancienne config

```sh
git show v0-legacy:bash/.bashrc          # source des 5 fonctions à reprendre
git show v0-legacy:zsh/.zshrc            # ancien zshrc (référence)
git show v0-legacy:starship/starship.toml
git show v0-legacy:kitty/kitty.conf
git checkout v0-legacy -- <path>         # restaurer un fichier
```

## Reprise après réinstallation machine

1. **AVANT de réinstaller** — pousser TOUT sur GitHub (sinon perdu) :
   `git push origin main` (+ `git push --tags` par sécurité). Vérifier sur
   github.com que le dernier commit est bien présent.
2. Après réinstallation : `git clone git@github.com:Nagusika/dotfiles.git ~/dotfiles`.
3. Reconfigurer l'identité git (elle était **repo-local**, donc perdue) :
   `git -C ~/dotfiles config user.name Nagusika && git -C ~/dotfiles config user.email me@he.re`.
4. Lancer Claude Code dans `~/dotfiles` et dire : « reprends la refonte à E2, lis
   `docs/REFONTE.md` ». (La mémoire Claude locale ne survit pas à la réinstall ;
   ce fichier est le point de reprise.)
