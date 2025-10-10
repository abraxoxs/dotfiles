#!/usr/bin/env bash
set -euo pipefail

#############################
# === EDIT THESE ===
NEW_USER="sbaulesc"               # non-root user to create
SSH_PUBKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDfAnxM/HVWDJVpn3M8vWXssHJHYCrTqekMz3++s6yqJ8ItKusMaZtP4Mc+7flbkAtVd1pdej+IzxSPJLPtU3RWlH9ch8xEkqkmKHVUCPfzgKcc+8CIQBCdEH2hQI9qNFCMPjEAXaSc75P6nqr8EGJub0t3UiVBRgru0TeniQohB9/gCw8EDY+qTj1vlRAEdhLZJWxzFo/uzskPPPc5kFmesO94kBllu0EdOEI/O7cdIU8e0H0LZf5KXO/YHd4W7g5oYVfK36oDnme70I4yixzsmOMNMWLhrHLjoKhcrGAsgKJIPxG+wX931R2FAiCBYc/iHIunHJpMfTLDcPVuikbJpile+S5eLFWN0x2/4SlJRTkmjBWTffMqP9N+LrxkAPKpcx75OMdpzqhwbsySbJsyFPEp9CZDzvJH0BarI+UFyMS2ug5ocVI6sIaCRlj+ETZxAREKSI3Np0gEyUsDOqCTv+VDZPrIFOcPGHvVf5rhZrTpsmg2nkIrLIbivJc4Drs= sven.baulesch@pt.lu"  # paste your public key here
TZ_SET="Europe/Luxembourg" 
#############################

log() { echo -e "\033[1;32m[+] $*\033[0m"; }
warn() { echo -e "\033[1;33m[!] $*\033[0m"; }
err() { echo -e "\033[1;31m[✗] $*\033[0m" >&2; }

need_root() {
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    err "Please run as root (sudo)."
    exit 1
  fi
}

is_installed() { dpkg -s "$1" &>/dev/null; }
ensure_pkg() {
  local pkgs=()
  for p in "$@"; do
    if ! is_installed "$p"; then pkgs+=("$p"); fi
  done
  if ((${#pkgs[@]})); then
    log "Installing: ${pkgs[*]}"
    apt-get update -qq
    DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}"
  fi
}

create_user_and_ssh() {
  local user="$1" key="$2"
  if ! id -u "$user" &>/dev/null; then
    log "Creating user: $user"
    adduser --disabled-password --gecos "" "$user"
    usermod -aG sudo "$user"

    # Set up passwordless sudo for the user
    log "Configuring passwordless sudo for $user"
    echo "$user ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$user"
    chmod 440 "/etc/sudoers.d/$user"
    
    # Ensure the account is locked (no password login)
    usermod -L "$user"
    log "User $user configured with passwordless sudo and locked password"
  else
    log "User $user already exists, skipping create."

    # Still ensure passwordless sudo is configured
    if [[ ! -f "/etc/sudoers.d/$user" ]]; then
      log "Adding passwordless sudo for existing user $user"
      echo "$user ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$user"
      chmod 440 "/etc/sudoers.d/$user"
    fi
  fi

  local sshdir="/home/${user}/.ssh"
  mkdir -p "$sshdir"
  chmod 700 "$sshdir"
  touch "$sshdir/authorized_keys"
  chmod 600 "$sshdir/authorized_keys"

  if [[ -n "$key" ]]; then
    if ! grep -qF "$key" "$sshdir/authorized_keys"; then
      echo "$key" >> "$sshdir/authorized_keys"
      log "Added public key to ${sshdir}/authorized_keys"
    else
      log "Public key already present."
    fi
  else
    warn "SSH_PUBKEY is empty; key-based SSH will not work."
  fi
  chown -R "${user}:${user}" "$sshdir"
}

base_tools() {
  log "Installing base tools"
  ensure_pkg curl vim htop net-tools git ncdu iftop iotop ca-certificates
}

detect_lxc_note() {
  if systemd-detect-virt -c | grep -qi "lxc"; then
    log "Running inside an LXC container (detected)."
  else
    warn "LXC not detected via systemd-detect-virt; continuing anyway."
  fi
}

set_timezone() {
  if [[ -n "${TZ_SET}" ]]; then
    log "Setting timezone to ${TZ_SET}"
    timedatectl set-timezone "${TZ_SET}" || warn "Could not set timezone"
  fi
}


lock_root() {
  log "Locking root password"
  passwd -l root || true
}

main() {
  need_root
  detect_lxc_note

  log "Updating system"
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get full-upgrade -y

  base_tools
#  set_timezone
#  set_hostname_safe
  create_user_and_ssh "$NEW_USER" "$SSH_PUBKEY"
#  hardening_ssh
#  setup_ufw
#  enable_unattended
#  timesync
#  journald_tuning
#  fail2ban

  log "Cleaning up"
  apt-get autoremove -y
  apt-get clean
  lock_root

  log "All done ✅"
  log "Try SSH as '${NEW_USER}'. If SSH is remote, KEEP THIS SESSION OPEN until you confirm access."
}

main "$@"
