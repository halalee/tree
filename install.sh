#!/usr/bin/env bash
set -e

# ==========================================================
# TREE Framework - Automated Installer
# Handles dependency checks, overrides PEP 668, sets up symlinks
# ==========================================================

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[-] Please run install.sh with sudo or as root.${NC}"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if already installed
if command -v tree-sec &>/dev/null && [ -f "/usr/local/bin/tree-sec" ]; then
    echo -e "${YELLOW}[*] Existing TREE installation detected.${NC}"
    echo -e "${BLUE}[*] Updating core files and verifying dependencies...${NC}"
else
    echo -e "${GREEN}[*] Performing fresh installation of TREE framework...${NC}"
fi

# 1. System Packages (Check before installing)
echo -e "${BLUE}[*] Checking system packages...${NC}"
REQUIRED_SYS_PKGS=(nmap netdiscover exploitdb python3 python3-pip)
MISSING_SYS_PKGS=()

for pkg in "${REQUIRED_SYS_PKGS[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
        MISSING_SYS_PKGS+=("$pkg")
    fi
done

if [ ${#MISSING_SYS_PKGS[@]} -gt 0 ]; then
    echo -e "${YELLOW}[*] Installing missing system packages: ${MISSING_SYS_PKGS[*]}...${NC}"
    apt-get update -y
    apt-get install -y "${MISSING_SYS_PKGS[@]}"
else
    echo -e "${GREEN}[+] All required system packages are present.${NC}"
fi

# 2. Python Packages (Bypass PEP 668 externally-managed environment if OS resists)
echo -e "${BLUE}[*] Checking Python dependencies...${NC}"
if [ -f "$SCRIPT_DIR/requirements.txt" ]; then
    # --break-system-packages overrides Debian 12 / Kali externally managed blocks
    # --ignore-installed ensures broken or partial packages are replaced cleanly
    python3 -m pip install -r "$SCRIPT_DIR/requirements.txt" \
        --break-system-packages \
        --ignore-installed \
        --no-warn-script-location || {
            echo -e "${YELLOW}[!] Retrying with forced user installation...${NC}"
            python3 -m pip install -r "$SCRIPT_DIR/requirements.txt" \
                --break-system-packages \
                --force-reinstall
        }
    echo -e "${GREEN}[+] Python dependencies verified and installed.${NC}"
fi

# 3. Global Command Setup (Creates an executable wrapper in system PATH)
echo -e "${BLUE}[*] Configuring 'tree-sec' system command...${NC}"
chmod +x "$SCRIPT_DIR/tree"

cat << 'EOF' > /usr/local/bin/tree-sec
#!/usr/bin/env bash
INSTALL_DIR="$(dirname "$(readlink -f "$0")")"
# If installed via standard symlink or wrapper
TARGET_SCRIPT="/home/kali/tree-framework/tree"
if [ ! -f "$TARGET_SCRIPT" ]; then
    TARGET_SCRIPT="$(find / -name "tree" -path "*/tree-framework/tree" 2>/dev/null | head -n 1)"
fi

exec python3 "$TARGET_SCRIPT" "$@"
EOF

# Ensure secondary fallback symlink in /usr/bin
chmod +x /usr/local/bin/tree-sec
ln -sf /usr/local/bin/tree-sec /usr/bin/tree-sec

# 4. Network & DNS Tuning (Enforce IPv4 priority to prevent API timeouts)
if ! grep -q "precedence ::ffff:0:0/96 100" /etc/gai.conf 2>/dev/null; then
    echo "precedence ::ffff:0:0/96 100" >> /etc/gai.conf
    echo -e "${GREEN}[+] Set IPv4 precedence in /etc/gai.conf${NC}"
fi

echo -e "\n${GREEN}====================================================${NC}"
echo -e "${GREEN}[+] Setup Complete!${NC}"
echo -e "${BLUE}[*] You can now run the tool from anywhere using:${NC}"
echo -e "    ${YELLOW}sudo tree-sec${NC}"
echo -e "${GREEN}====================================================${NC}\n"
