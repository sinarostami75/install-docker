#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------
# Docker Installer for Ubuntu (Official Repo)
# Install modes are selected at the START of the script
# ---------------------------------------------------------

SCRIPT_NAME="$(basename "$0")"

MODE="custom"          # simple | dev | server | custom
NON_INTERACTIVE=false
ENABLE_NON_ROOT=false
INSTALL_COMPOSE=true
DEMO="none"

log()  { printf "[%s] %s\n" "$(date +'%H:%M:%S')" "$*"; }
warn() { printf "[%s] WARNING: %s\n" "$(date +'%H:%M:%S')" "$*" >&2; }
die()  { printf "[%s] ERROR: %s\n" "$(date +'%H:%M:%S')" "$*" >&2; exit 1; }

trap 'die "Failed near line $LINENO"' ERR

cmd_exists() { command -v "$1" >/dev/null 2>&1; }

is_ubuntu() {
  [[ -f /etc/os-release ]] || return 1
  . /etc/os-release
  [[ "${ID:-}" == "ubuntu" ]]
}

as_root_prefix() {
  if [[ "$(id -u)" -eq 0 ]]; then
    echo ""
  else
    cmd_exists sudo || die "Run as root or install sudo"
    echo "sudo"
  fi
}

prompt_mode() {
  echo
  echo "Select installation mode:"
  echo "1) Simple    (Docker only, safest)"
  echo "2) Dev       (Docker + Compose + non-root + nginx demo)"
  echo "3) Server    (Docker + Compose, sudo only, no demo)"
  echo "4) Custom    (Choose options manually)"
  echo
  read -r -p "Enter choice [1-4] (default: 2): " choice
  choice="${choice:-2}"

  case "$choice" in
    1)
      MODE="simple"
      INSTALL_COMPOSE=false
      ENABLE_NON_ROOT=false
      DEMO="none"
      ;;
    2)
      MODE="dev"
      INSTALL_COMPOSE=true
      ENABLE_NON_ROOT=true
      DEMO="nginx"
      ;;
    3)
      MODE="server"
      INSTALL_COMPOSE=true
      ENABLE_NON_ROOT=false
      DEMO="none"
      ;;
    4)
      MODE="custom"
      ;;
    *)
      warn "Invalid choice. Using Dev mode."
      MODE="dev"
      INSTALL_COMPOSE=true
      ENABLE_NON_ROOT=true
      DEMO="nginx"
      ;;
  esac
}

prompt_custom_options() {
  read -r -p "Install Docker Compose plugin? [y/n] (default: y): " a
  [[ "${a:-y}" =~ ^[Yy]$ ]] && INSTALL_COMPOSE=true || INSTALL_COMPOSE=false

  read -r -p "Enable non-root Docker usage? [y/n] (default: n): " b
  [[ "${b:-n}" =~ ^[Yy]$ ]] && ENABLE_NON_ROOT=true || ENABLE_NON_ROOT=false

  echo "Run demo after install?"
  echo "1) none"
  echo "2) hello-world"
  echo "3) nginx"
  read -r -p "Choose [1-3] (default: 1): " c
  c="${c:-1}"

  case "$c" in
    2) DEMO="hello" ;;
    3) DEMO="nginx" ;;
    *) DEMO="none" ;;
  esac
}

ensure_tools() {
  local SUDO="$1"
  local pkgs=()

  cmd_exists apt-get || die "apt-get not found"

  cmd_exists curl || pkgs+=("curl")
  cmd_exists gpg || pkgs+=("gnupg")
  cmd_exists dpkg || pkgs+=("dpkg")
  cmd_exists lsb_release || pkgs+=("lsb-release")
  cmd_exists ca-certificates || pkgs+=("ca-certificates")

  if [[ ${#pkgs[@]} -gt 0 ]]; then
    log "Installing missing tools: ${pkgs[*]}"
    $SUDO apt-get update -y
    $SUDO apt-get install -y "${pkgs[@]}"
  fi
}

main() {
  is_ubuntu || die "Ubuntu only"
  local SUDO
  SUDO="$(as_root_prefix)"

  prompt_mode
  [[ "$MODE" == "custom" ]] && prompt_custom_options

  ensure_tools "$SUDO"

  log "Install mode: $MODE"
  log "Compose: $INSTALL_COMPOSE | Non-root: $ENABLE_NON_ROOT | Demo: $DEMO"

  log "Adding Docker repository..."
  $SUDO install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  $SUDO chmod a+r /etc/apt/keyrings/docker.gpg

  ARCH="$(dpkg --print-architecture)"
  CODENAME="$(lsb_release -cs)"

  echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $CODENAME stable"     | $SUDO tee /etc/apt/sources.list.d/docker.list >/dev/null

  $SUDO apt-get update -y

  log "Installing Docker..."
  if [[ "$INSTALL_COMPOSE" == "true" ]]; then
    $SUDO apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  else
    $SUDO apt-get install -y docker-ce docker-ce-cli containerd.io
  fi

  $SUDO systemctl enable --now docker
  docker --version

  if [[ "$ENABLE_NON_ROOT" == "true" ]]; then
    USERNAME="${SUDO_USER:-$(id -un)}"
    $SUDO groupadd -f docker
    $SUDO usermod -aG docker "$USERNAME"
    warn "Log out and log in again to use docker without sudo"
  fi

  if [[ "$DEMO" == "hello" ]]; then
    $SUDO docker run --rm hello-world
  elif [[ "$DEMO" == "nginx" ]]; then
    $SUDO docker run -d --name demo-nginx -p 8080:80 nginx:alpine
    log "Open http://localhost:8080"
  fi

  log "Done."
}

main "$@"
