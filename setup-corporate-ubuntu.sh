#!/usr/bin/env bash
#===============================================================================
# setup-corporate-ubuntu.sh
# Corporate Ubuntu onboarding script for Entra ID / Intune integration
#
# Supports: Ubuntu 22.04 LTS, 26.04 LTS
# Installs: Microsoft Edge, Intune Portal, Defender for Endpoint
# Configures: LUKS check, Microsoft APT repos, device registration
#
# Usage: sudo bash setup-corporate-ubuntu.sh
#===============================================================================

set -euo pipefail

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC}  $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# --- Pre-flight checks ---
preflight() {
    log "Running pre-flight checks..."

    # Must be root
    [[ $EUID -eq 0 ]] || err "This script must be run as root (use sudo)."

    # Check Ubuntu version
    source /etc/os-release
    if [[ "$ID" != "ubuntu" ]]; then
        err "This script only supports Ubuntu. Detected: $ID"
    fi

    if [[ "$VERSION_ID" != "22.04" && "$VERSION_ID" != "26.04" ]]; then
        warn "Untested Ubuntu version: $VERSION_ID. Proceed with caution."
    fi

    log "Detected: $PRETTY_NAME"

    # Check internet connectivity
    if ! ping -c 1 packages.microsoft.com &>/dev/null; then
        err "No internet connectivity. Cannot reach packages.microsoft.com."
    fi

    # Check LUKS disk encryption
    if lsblk -o TYPE | grep -q "crypt"; then
        log "LUKS disk encryption detected — compliant."
    else
        warn "No LUKS encryption detected. Intune compliance will flag this."
        warn "Consider encrypting your disk before enrolling."
    fi
}

# --- Add Microsoft APT repositories ---
setup_microsoft_repos() {
    log "Adding Microsoft APT repositories..."

    # Install prerequisites
    apt-get update -qq
    apt-get install -y -qq curl gpg apt-transport-https software-properties-common

    # Microsoft GPG key
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | \
        gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg

    # Edge repository
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] \
https://packages.microsoft.com/repos/edge stable main" \
        > /etc/apt/sources.list.d/microsoft-edge.list

    # Intune / Microsoft prod repository
    source /etc/os-release
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] \
https://packages.microsoft.com/ubuntu/${VERSION_ID}/prod ${UBUNTU_CODENAME} main" \
        > /etc/apt/sources.list.d/microsoft-prod.list

    apt-get update -qq
    log "Microsoft repositories added."
}

# --- Install Microsoft Edge ---
install_edge() {
    if command -v microsoft-edge-stable &>/dev/null; then
        log "Microsoft Edge already installed. Skipping."
        return
    fi

    log "Installing Microsoft Edge..."
    apt-get install -y -qq microsoft-edge-stable
    log "Microsoft Edge installed."
}

# --- Install Intune Portal ---
install_intune() {
    if dpkg -l intune-portal &>/dev/null 2>&1; then
        log "Intune Portal already installed. Skipping."
        return
    fi

    log "Installing Microsoft Intune Portal..."
    apt-get install -y -qq intune-portal
    log "Intune Portal installed."
}

# --- Install Microsoft Defender for Endpoint ---
install_defender() {
    if command -v mdatp &>/dev/null; then
        log "Microsoft Defender for Endpoint already installed. Skipping."
        return
    fi

    log "Installing Microsoft Defender for Endpoint..."
    apt-get install -y -qq mdatp

    # Enable real-time protection
    mdatp config real-time-protection --value enabled 2>/dev/null || \
        warn "Could not enable real-time protection. Configure manually after onboarding."

    log "Defender for Endpoint installed."
    warn "You must onboard Defender using your tenant's onboarding script/package."
    warn "Download it from: Microsoft Defender portal > Settings > Endpoints > Onboarding"
}

# --- Basic security hardening ---
harden_system() {
    log "Applying basic security hardening..."

    # Enable UFW firewall
    if command -v ufw &>/dev/null; then
        ufw --force enable
        ufw default deny incoming
        ufw default allow outgoing
        log "UFW firewall enabled (deny incoming, allow outgoing)."
    fi

    # Disable root SSH login
    SSHD_CONFIG="/etc/ssh/sshd_config"
    if [[ -f "$SSHD_CONFIG" ]]; then
        sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$SSHD_CONFIG"
        sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' "$SSHD_CONFIG"
        systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null || true
        log "SSH hardened: root login disabled, password auth disabled."
    fi

    # Auto security updates
    apt-get install -y -qq unattended-upgrades
    dpkg-reconfigure -plow unattended-upgrades 2>/dev/null || true
    log "Unattended security upgrades enabled."
}

# --- Summary ---
print_summary() {
    echo ""
    echo "==============================================================================="
    echo -e "${GREEN} Ubuntu Corporate Onboarding Complete${NC}"
    echo "==============================================================================="
    echo ""
    echo " Next steps for the user:"
    echo "  1. Open Microsoft Edge"
    echo "  2. Sign in with your corporate Entra ID account"
    echo "  3. Open Intune Portal and complete device registration"
    echo "  4. Verify compliance status in Intune Portal"
    echo ""
    echo " For OneDrive file access:"
    echo "  - Use OneDrive via Edge (web), or"
    echo "  - Install rclone: sudo apt install rclone && rclone config"
    echo ""
    echo " Defender onboarding:"
    echo "  - Download your tenant onboarding package from the Defender portal"
    echo "  - Run: sudo mdatp health  (to verify status)"
    echo ""
    echo "==============================================================================="
}

# --- Main ---
main() {
    echo "==============================================================================="
    echo " Ubuntu Corporate Onboarding — Entra ID / Intune"
    echo "==============================================================================="
    echo ""

    preflight
    setup_microsoft_repos
    install_edge
    install_intune
    install_defender
    harden_system
    print_summary
}

main "$@"
