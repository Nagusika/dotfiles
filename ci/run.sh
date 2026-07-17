#!/bin/sh
# ci/run.sh — exécuté dans un conteneur VIERGE en root. Installe le minimum,
# crée un utilisateur non-root sudo, lance bootstrap+doctor (profil default),
# puis quelques lints sur les configs (outils désormais présents).
# Monté : le repo en lecture seule dans /work.
set -eu

# 1. Prérequis pour cloner + bootstrapper, selon la famille de la distro.
if command -v apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y -qq sudo git curl ca-certificates >/dev/null
elif command -v dnf >/dev/null 2>&1; then
  dnf install -y -q sudo git curl >/dev/null
elif command -v pacman >/dev/null 2>&1; then
  pacman -Sy --noconfirm --needed sudo git curl >/dev/null
fi

# 2. Utilisateur non-root avec sudo NOPASSWD (exerce le chemin sudo du bootstrap).
id tester >/dev/null 2>&1 || useradd -m -s /bin/bash tester
printf 'tester ALL=(ALL) NOPASSWD:ALL\n' > /etc/sudoers.d/tester
chmod 0440 /etc/sudoers.d/tester

# 3. Copie du repo (monté ro) et cession au tester.
cp -a /work /home/tester/dotfiles
chown -R tester:tester /home/tester/dotfiles

# 4. Bootstrap + doctor.
su - tester -c 'cd ~/dotfiles && ./bootstrap.sh default'
su - tester -c 'cd ~/dotfiles && ./doctor.sh'

# 5. Lints post-install (bash/zsh/vim/dash désormais disponibles).
su - tester -c 'set -eu; cd ~/dotfiles
  for f in lib/*.sh bootstrap.sh doctor.sh modules/*/module.sh; do bash -n "$f"; done
  bash -n modules/shell/home/.bashrc
  command -v zsh  >/dev/null 2>&1 && zsh -n modules/shell/home/.zshrc
  command -v vim  >/dev/null 2>&1 && vim -u modules/vim/home/.vimrc -es -c "qa!"
  command -v dash >/dev/null 2>&1 && dash -n modules/shell/home/.config/sh/common.sh \
                                             modules/shell/home/.config/sh/aliases.sh \
                                             modules/shell/home/.config/sh/functions.sh
  echo "  lints OK"'

echo "=== CI OK : $(. /etc/os-release; echo "$PRETTY_NAME") ==="
