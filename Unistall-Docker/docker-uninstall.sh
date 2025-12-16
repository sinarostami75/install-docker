#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------
# Docker Uninstaller for Ubuntu (Complete Removal)
# ---------------------------------------------------------

log()  { printf "[%s] %s\n" "$(date +'%H:%M:%S')" "$*"; }
warn() { printf "[%s] WARNING: %s\n" "$(date +'%H:%M:%S')" "$*" >&2; }
die()  { printf "[%s] ERROR: %s\n" "$(date +'%H:%M:%S')" "$*" >&2; exit 1; }

trap 'die "Failed near line $LINENO. Check output above."' ERR

cmd_exists() { command -v "$1" >/dev/null 2>&1; }

as_root_prefix() {
  if [[ "$(id -u)" -eq 0 ]]; then
    echo ""
  else
    cmd_exists sudo || die "Run as root or install sudo"
    echo "sudo"
  fi
}

confirm() {
  local msg="$1"
  read -r -p "$msg [y/N]: " ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

main() {
  [[ -f /etc/os-release ]] || die "Cannot detect OS"
  . /etc/os-release
  [[ "$ID" == "ubuntu" ]] || die "This script supports Ubuntu only"

  local SUDO
  SUDO="$(as_root_prefix)"

  echo
  warn "This will COMPLETELY remove Docker from this system."
  warn "Images, containers, volumes, and networks will be deleted."
  echo

  confirm "Do you want to continue?" || { log "Aborted."; exit 0; }

  if cmd_exists docker; then
    log "Stopping Docker service..."
    $SUDO systemctl stop docker || true
  fi

  log "Removing Docker packages..."
  $SUDO apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras || true

  log "Removing unused dependencies..."
  $SUDO apt-get autoremove -y
  $SUDO apt-get autoclean -y

  log "Removing Docker data directories..."
  $SUDO rm -rf /var/lib/docker
  $SUDO rm -rf /var/lib/containerd

  log "Removing Docker configuration..."
  $SUDO rm -rf /etc/docker
  $SUDO rm -rf /etc/systemd/system/docker.service.d

  log "Removing Docker repository and keys..."
  $SUDO rm -f /etc/apt/sources.list.d/docker.list
  $SUDO rm -f /etc/apt/keyrings/docker.gpg

  log "Reloading systemd..."
  $SUDO systemctl daemon-reload

  log "Docker has been completely removed."
  log "A system reboot is recommended."
}

main "$@"
