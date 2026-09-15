#!/usr/bin/env bash
set -e

# TREE Framework Installer for Kali Linux
# Ensures all system packages, exploit-db databases, and Python libraries are configured.

if [ "$EUID" -ne 0 ]; then
  echo -e "\033[0;31m[-] Please run install.sh with sudo / root privileges.\033[0m"
  exit 1
fi

echo -e "\033[0;32m[*] Updating package lists and installing core dependencies...\033[0m"
apt-get update -y
apt-get install -y \
  nmap \
  netdiscover \
  exploitdb \
  python3 \
  python3-pip \
  python3-bs4 \
  python3-markdown \
  python3-nmap \
  python3-requests

echo -e "\033[0;32m[*] Installing Python dependencies...\033[0m"
pip install -r requirements.txt --break-system-packages

echo -e "\033[0;32m[*] Setting up binary symlink...\033[0m"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "$SCRIPT_DIR/tree"
ln -sf "$SCRIPT_DIR/tree" /usr/local/bin/tree-sec
ln -sf "$SCRIPT_DIR/tree" /usr/bin/tree-sec

echo -e "\033[0;32m[*] Checking IPv6 / DNS resolver configuration...\033[0m"
# Ensure IPv4 precedence to prevent Google API timeouts
if ! grep -q "precedence ::ffff:0:0/96 100" /etc/gai.conf 2>/dev/null; then
  echo "precedence ::ffff:0:0/96 100" >> /etc/gai.conf
  echo -e "\033[0;34m[+] Configured IPv4 precedence in /etc/gai.conf\033[0m"
fi

echo -e "\033[0;32m[+] Installation completed successfully!\033[0m"
echo -e "\033[0;36m[*] Run 'sudo tree-sec' from anywhere to launch the console.\033[0m"
