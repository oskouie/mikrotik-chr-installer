#!/bin/bash
# =============================================================
#  MikroTik CHR - One-Line Installer Entry Point
#  Usage:
#    curl -fsSL https://raw.githubusercontent.com/oskouie/mikrotik-chr-installer/main/run.sh | sudo bash
#  OR:
#    wget -qO- https://raw.githubusercontent.com/oskouie/mikrotik-chr-installer/main/run.sh | sudo bash
# =============================================================

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
log()   { echo -e "${GREEN}[+]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }
info()  { echo -e "${CYAN}[i]${NC} $1"; }

# ─── Root Check ────────────────────────────────────────────────
[[ $EUID -ne 0 ]] && error "Run as root: curl ... | sudo bash"

# ─── GitHub Config ─────────────────────────────────────────────
GITHUB_USER="oskouie"
REPO_NAME="mikrotik-chr-installer"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/${GITHUB_USER}/${REPO_NAME}/${BRANCH}"

# ─── Check Dependencies ────────────────────────────────────────
log "Checking dependencies..."
if ! command -v curl &>/dev/null && ! command -v wget &>/dev/null; then
    apt-get update -qq && apt-get install -y -qq curl
fi

# ─── Download & Run Main Script ────────────────────────────────
TMPFILE=$(mktemp /tmp/install-chr-XXXXXX.sh)
trap "rm -f $TMPFILE" EXIT

log "Downloading installer..."
if command -v curl &>/dev/null; then
    curl -fsSL "${RAW_BASE}/install-chr.sh" -o "$TMPFILE"
else
    wget -qO "$TMPFILE" "${RAW_BASE}/install-chr.sh"
fi

chmod +x "$TMPFILE"
info "Launching MikroTik CHR installer..."
echo ""
bash "$TMPFILE"
