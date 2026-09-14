#!/usr/bin/env bash

# TREE Framework - Automated Installer
# Target OS: Debian / Ubuntu / Kali Linux

set -e

# ANSI Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}"
echo "======================================================"
echo "          TREE Framework - Automated Installer         "
echo "======================================================"
echo -e "${NC}"

# Check for root / sudo permissions
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[-] Please run the installer with sudo: sudo ./install.sh${NC}"
    exit 1
fi

INSTALL_DIR="/opt/tree-framework"
BIN_TARGET="/usr/bin/tree-sec"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}[*] Updating package index...${NC}"
apt-get update -y

echo -e "${BLUE}[*] Installing system dependencies (nmap, netdiscover, python3)...${NC}"
apt-get install -y nmap netdiscover python3 python3-pip python3-venv python3-cryptography python3-cffi python3-markdown

echo -e "${BLUE}[*] Installing Python libraries...${NC}"
pip3 install -r "$SCRIPT_DIR/requirements.txt" --break-system-packages

echo -e "${BLUE}[*] Setting up framework directory in ${INSTALL_DIR}...${NC}"
mkdir -p "$INSTALL_DIR"
cp -r "$SCRIPT_DIR"/* "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/tree"

echo -e "${BLUE}[*] Creating global system symlinks...${NC}"
# Primary safe command
ln -sf "$INSTALL_DIR/tree" "$BIN_TARGET"

# Optional: Link to 'tree' if user wants it, backing up original /usr/bin/tree if present
if [ -f /usr/bin/tree ] && [ ! -L /usr/bin/tree ]; then
    echo -e "${YELLOW}[!] Existing /usr/bin/tree directory tool detected. Backing it up to /usr/bin/tree.orig...${NC}"
    mv /usr/bin/tree /usr/bin/tree.orig
fi
ln -sf "$INSTALL_DIR/tree" /usr/bin/tree

echo -e "${GREEN}"
echo "======================================================"
echo "          Installation Completed Successfully!        "
echo "======================================================"
echo -e "${NC}"
echo -e "You can now run the tool from anywhere using either:"
echo -e "  ${YELLOW}sudo tree-sec${NC}  or  ${YELLOW}sudo tree${NC}"
echo ""
