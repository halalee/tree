#!/usr/bin/env bash
# ==========================================================
# TREE Framework - Automated Stealth Animated Installer
# ==========================================================

LOG_FILE="/tmp/tree_install.log"
rm -f "$LOG_FILE"
touch "$LOG_FILE"

# Colors
GREEN="\033[0;32m"
CYAN="\033[0;36m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
BROWN="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m"

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[-] Please execute install.sh with sudo or as root.${NC}"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Trap Ctrl+C to unhide cursor cleanly
trap 'tput cnorm; echo -e "\n${RED}[!] Installation interrupted.${NC}"; exit 1' INT TERM

# Ensure terminal cursor is restored on exit
cleanup() {
    tput cnorm
}
trap cleanup EXIT

# Clear screen & hide cursor
clear
tput civis

# Animation Stages
stage_1() {
cat << "EOF"
        _  _
       ( \/ )
        \  /   🚿
         \/     :
                .
           .
          (.)
    ~~~~~~~~~~~~~~
EOF
}

stage_2() {
cat << "EOF"
        _  _
       ( \/ )
        \  /   🚿
         \/     :
                .
           🌱
    ~~~~~~~~~~~~~~
EOF
}

stage_3() {
cat << "EOF"
        _  _
       ( \/ )
        \  /   🚿
         \/     :
          \ | /
           \|/
            |
            |
    ~~~~~~~~~~~~~~
EOF
}

stage_4() {
cat << "EOF"
           &&&
         &&&&&&
        &&&|&&&&
           | /
           |/
           |
    ~~~~~~~~~~~~~~
EOF
}

stage_5() {
cat << "EOF"
         ,@@@@@@@,
       ,,@@@@|@@@@@@,
      &&&&&&&|&&&&&&&&
       &&&&&&|/&&&&&&
           { | }
            \|/
             |
             |
    ~~~~~~~~~~~~~~~~~~
EOF
}

stage_6() {
cat << "EOF"
         ,@@@@@@@,
       ,,@@@@|@@@@@@,
      &&&%#%&|&&%#%&&&
     &&%#%#%&|&%#%#%&&&
      &&&%#%&|/&&%#%&&
           { | }
            \|/
             |
             |
    ~~~~~~~~~~~~~~~~~~
EOF
}

# The actual background installation worker
install_worker() {
    # 1. System packages
    apt-get update -y >> "$LOG_FILE" 2>&1
    apt-get install -y \
        nmap \
        netdiscover \
        exploitdb \
        python3 \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        python3-bs4 \
        python3-markdown \
        python3-requests >> "$LOG_FILE" 2>&1

    # 2. Force install all Python packages for both user and root
    REQUIRED_PY_MODULES=(
        "rich>=13.7.0"
        "beautifulsoup4>=4.12.0"
        "requests>=2.31.0"
        "xhtml2pdf>=0.2.16"
        "markdown>=3.6"
        "python-nmap>=0.7.1"
        "google-genai>=0.1.1"
    )

    for mod in "${REQUIRED_PY_MODULES[@]}"; do
        python3 -m pip install "$mod" --break-system-packages --ignore-installed >> "$LOG_FILE" 2>&1 || true
    done

    if [ -f "$SCRIPT_DIR/requirements.txt" ]; then
        python3 -m pip install -r "$SCRIPT_DIR/requirements.txt" --break-system-packages --ignore-installed >> "$LOG_FILE" 2>&1 || true
    fi

    # 3. Create global executable wrapper
    chmod +x "$SCRIPT_DIR/tree"

    cat << EOF > /usr/local/bin/tree-sec
#!/usr/bin/env bash
exec python3 "$SCRIPT_DIR/tree" "\$@"
EOF
    chmod +x /usr/local/bin/tree-sec
    ln -sf /usr/local/bin/tree-sec /usr/bin/tree-sec

    # 4. Network and DNS IPv4 tuning
    if ! grep -q "precedence ::ffff:0:0/96 100" /etc/gai.conf 2>/dev/null; then
        echo "precedence ::ffff:0:0/96 100" >> /etc/gai.conf
    fi
}

# Start background installation
install_worker &
PID=$!

STAGES=(stage_1 stage_2 stage_3 stage_4 stage_5 stage_6)
MSG=(
    "Planting the seed & preparing system packages..."
    "Watering the seed & configuring build utilities..."
    "Sprouting roots & fetching exploit databases..."
    "Growing branches & building Python environments (rich, genai, nmap)..."
    "Budding leaves & linking global binary wrappers..."
    "Blooming into TREE framework..."
)

idx=0
total_stages=${#STAGES[@]}

while kill -0 $PID 2>/dev/null; do
    tput cup 0 0
    echo -e "${CYAN}======================================================${NC}"
    echo -e "${GREEN}             TREE FRAMEWORK INSTALLATION              ${NC}"
    echo -e "${CYAN}======================================================${NC}\n"

    ${STAGES[$idx]}
    
    echo -e "\n${YELLOW}[*] ${MSG[$idx]}${NC}"
    echo -e "${BLUE}[~] Working quietly in the background...${NC}\n"

    idx=$(( (idx + 1) % total_stages ))
    sleep 2.5
done

wait $PID
INSTALL_EXIT_CODE=$?

clear
tput cnorm

if [ $INSTALL_EXIT_CODE -ne 0 ]; then
    echo -e "${RED}[-] Installation failed. Details from $LOG_FILE:${NC}\n"
    tail -n 25 "$LOG_FILE"
    exit 1
fi

# Print final mature tree banner
echo -e "${GREEN}"
cat << "EOF"
         ,@@@@@@@,
       ,,@@@@|@@@@@@,
      &&&%#%&|&&%#%&&&
     &&%#%#%&|&%#%#%&&&
      &&&%#%&|/&&%#%&&
           { | }
            \|/
             |
             |
    ~~~~~~~~~~~~~~~~~~
EOF
echo -e "${NC}"

echo -e "${CYAN}======================================================${NC}"
echo -e "${GREEN}[+] TREE framework has grown and is ready!${NC}"
echo -e "${CYAN}======================================================${NC}"

# Verification check of modules
echo -e "\n${BLUE}[*] Performing integrity check on required imports...${NC}"
python3 -c "
import sys
required = ['rich', 'bs4', 'requests', 'xhtml2pdf', 'markdown', 'nmap', 'google.genai']
missing = []
for mod in required:
    try:
        __import__(mod)
        print(f' \033[0;32m[✓]\033[0m {mod}')
    except ImportError:
        missing.append(mod)
        print(f' \033[0;31m[✗]\033[0m {mod}')

if missing:
    sys.exit(1)
"

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}[✓] All imports verified successfully.${NC}"
    echo -e "${YELLOW}[*] Launch the console anytime using:${NC} ${GREEN}sudo tree-sec${NC}\n"
else
    echo -e "\n${RED}[!] Some Python modules failed to load. Check /tmp/tree_install.log for details.${NC}\n"
    exit 1
fi