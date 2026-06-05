#!/bin/bash
# =============================================================
#  MikroTik CHR Installer - Replaces Ubuntu with CHR
#  Compatible with: Ubuntu 24.04
#  WARNING: This will DESTROY all data on the disk!
# =============================================================

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
log()   { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }
info()  { echo -e "${CYAN}[i]${NC} $1"; }

# ─── Root Check ────────────────────────────────────────────────
[[ $EUID -ne 0 ]] && error "Run as root: sudo bash $0"

# ─── Banner ────────────────────────────────────────────────────
clear
echo -e "${CYAN}"
cat << 'EOF'
  __  __ _ _         _____    _  __    ____ _   _ ____  
 |  \/  (_) | _____  |_   _|  | |/ /   / ___| | | |  _ \ 
 | |\/| | | |/ / _ \   | |    | ' /   | |   | |_| | |_) |
 | |  | | |   < (_) |  | |    | . \   | |___|  _  |  _ < 
 |_|  |_|_|_|\_\___/   |_|    |_|\_\   \____|_| |_|_| \_\
         CHR Installer - Ubuntu Replacement Script
EOF
echo -e "${NC}"
echo -e "${RED}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  ⚠️  WARNING: ALL DATA ON THIS SERVER WILL BE ERASED!  ⚠️  ║${NC}"
echo -e "${RED}║     Ubuntu will be completely replaced by MikroTik CHR   ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# ─── Install Dependencies ──────────────────────────────────────
log "Installing required packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq wget curl unzip

# ─── Get Latest CHR Version ────────────────────────────────────
log "Fetching latest CHR version..."

# روش ۱: MikroTik upgrade API (سریع‌ترین)
LATEST_VERSION=$(curl -sf --max-time 10 \
    "https://upgrade.mikrotik.com/routeros/NEWESTa7.stable" 2>/dev/null | \
    awk '{print $1}' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' || echo "")

# روش ۲: scrape صفحه دانلود
if [[ -z "$LATEST_VERSION" ]]; then
    LATEST_VERSION=$(curl -sf --max-time 15 \
        "https://mikrotik.com/download/changelogs?channelFilter=stable" 2>/dev/null | \
        grep -oP '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "")
fi

# روش ۳: fallback به آخرین نسخه شناخته‌شده
if [[ -z "$LATEST_VERSION" ]]; then
    warn "Auto-detect failed. Using latest known stable version."
    LATEST_VERSION="7.23.1"
fi

info "CHR version: ${LATEST_VERSION}"

# ─── Verify Download URL Exists ────────────────────────────────
CHR_URL="https://download.mikrotik.com/routeros/${LATEST_VERSION}/chr-${LATEST_VERSION}.img.zip"
CHR_ZIP="/tmp/chr-${LATEST_VERSION}.img.zip"

log "Verifying download URL..."
HTTP_CODE=$(curl -sf --max-time 10 -o /dev/null -w "%{http_code}" "$CHR_URL" || echo "000")
if [[ "$HTTP_CODE" != "200" ]]; then
    warn "Version ${LATEST_VERSION} not found (HTTP ${HTTP_CODE}), trying fallback 7.23.1..."
    LATEST_VERSION="7.23.1"
    CHR_URL="https://download.mikrotik.com/routeros/${LATEST_VERSION}/chr-${LATEST_VERSION}.img.zip"
fi

info "Download URL: ${CHR_URL}"

# ─── Detect Target Disk ────────────────────────────────────────
log "Detecting primary disk..."
ROOT_PART=$(df / | tail -1 | awk '{print $1}')
BOOT_DISK=$(lsblk -no PKNAME "$ROOT_PART" 2>/dev/null | head -1)
BOOT_DISK="/dev/${BOOT_DISK}"

# fallback
if [[ ! -b "$BOOT_DISK" ]]; then
    BOOT_DISK=$(lsblk -d -o NAME,TYPE | awk '$2=="disk"{print "/dev/"$1}' | head -1)
fi
[[ ! -b "$BOOT_DISK" ]] && error "Could not detect target disk!"

DISK_SIZE=$(lsblk -d -o SIZE "$BOOT_DISK" | tail -1 | tr -d ' ')
info "Target disk : ${BOOT_DISK} (${DISK_SIZE})"

# ─── Confirmation ──────────────────────────────────────────────
echo ""
warn "This will PERMANENTLY erase: ${BOOT_DISK} (${DISK_SIZE})"
warn "Ubuntu will be gone. MikroTik CHR ${LATEST_VERSION} will be installed."
echo ""
read -rp "$(echo -e ${RED})Type 'YES' to confirm: $(echo -e ${NC})" CONFIRM
[[ "$CONFIRM" != "YES" ]] && error "Aborted."

# ─── Download ──────────────────────────────────────────────────
log "Downloading CHR ${LATEST_VERSION} ..."
wget -q --show-progress -O "$CHR_ZIP" "$CHR_URL" || \
    error "Download failed! Check internet connection."

# ─── Extract ───────────────────────────────────────────────────
log "Extracting image..."
unzip -o "$CHR_ZIP" -d /tmp/ 2>/dev/null || error "Extraction failed!"
CHR_IMG=$(find /tmp -maxdepth 1 -name "chr-*.img" | head -1)
[[ -z "$CHR_IMG" ]] && error "Image file not found after extraction!"
info "Image: ${CHR_IMG} ($(du -sh "$CHR_IMG" | cut -f1))"

# ─── Unmount ───────────────────────────────────────────────────
log "Unmounting partitions..."
lsblk -ln -o NAME "$BOOT_DISK" | tail -n +2 | while read -r part; do
    umount "/dev/$part" 2>/dev/null || true
done
swapoff -a 2>/dev/null || true

# ─── Write to Disk ─────────────────────────────────────────────
echo ""
echo -e "${RED}━━━ Writing CHR to ${BOOT_DISK} — DO NOT INTERRUPT ━━━${NC}"
echo ""
dd if="$CHR_IMG" of="$BOOT_DISK" bs=4M status=progress conv=fsync
sync

log "Write complete!"

# ─── Cleanup ───────────────────────────────────────────────────
rm -f "$CHR_ZIP" "$CHR_IMG"

# ─── Done ──────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║       ✅  MikroTik CHR ${LATEST_VERSION} Installed Successfully!     ║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║  Default user : admin                                    ║${NC}"
echo -e "${GREEN}║  Default pass : (empty — set it immediately!)            ║${NC}"
echo -e "${GREEN}║  Connect via  : WinBox or SSH                           ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
read -rp "$(echo -e ${YELLOW})Press ENTER to reboot into MikroTik CHR: $(echo -e ${NC})"
reboot
