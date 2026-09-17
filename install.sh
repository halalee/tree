#!/usr/bin/env bash
# ==============================================================================
# TREE Framework - Automated Lifecycle Installer & Manager
# Supports: Kali Linux, Debian, Ubuntu, WSL
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
LOG_FILE="/tmp/tree_installer.log"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[-] Error: This script must be run as root.${NC}"
    echo -e "${YELLOW}[!] Run: sudo ./install.sh${NC}"
    exit 1
fi

# ==============================================================================
# DEEP 8-STAGE GROWING TREE ANIMATION
# ==============================================================================

stage_1() {
cat << "ART"
               
               
               
               
               
               
         .  .  .  (preparing soil)
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ART
}

stage_2() {
cat << "ART"
               
               
               
               
               
               o  (seed planted)
              / \
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ART
}

stage_3() {
cat << "ART"
               
               
               
               
              \ /  (roots settling)
               o
              /|\
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ART
}

stage_4() {
cat << "ART"
               
               
               
              \o/  (first sprout)
               |
               |
              /|\
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ART
}

stage_5() {
cat << "ART"
               
              /^\
             /   \  (sapling branching)
            /     \
               |
               |
              /|\
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ART
}

stage_6() {
cat << "ART"
               *
              / \
             /   \
            /_____\  (canopy forming)
            /     \
           /_______\
              |||
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ART
}

stage_7() {
cat << "ART"
               *
              / \
             /   \
            /=====\
           /       \  (branches deepening)
          /=========\
         /           \
        /_____________\
              |||
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ART
}

stage_8() {
cat << "ART"
               *
              / \
             /   \
            /=====\
           /  * *  \
          /=========\  (fully matured)
         /   *   *   \
        /=============\
       /  *    *    *  \
      /_________________\
              |||
             /|||\
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ART
}

# UPDATE: Shears Pruning
groom_1() {
cat << "ART"
       >--8        *
                  / \
                 /   \
                /=====\
ART
}
groom_2() {
cat << "ART"
                 *  8--<
                / \
               /   \
              /=====\
ART
}
groom_3() {
cat << "ART"
            *
           / \   >--8
          /   \
         /=====\
ART
}
groom_4() {
cat << "ART"
            *
           / \
          /   \  8--<
         /=====\
ART
}

# REMOVE: Chopping
chop_1() {
cat << "ART"
            *
           / \
          /   \
           |||   <--[══╣
ART
}
chop_2() {
cat << "ART"
            *
           / \
          /   \
           |||====* CHOP!
ART
}
chop_3() {
cat << "ART"
           \  *
            \  \
             \  \
           |||
ART
}
chop_4() {
cat << "ART"
                 __________ (timber)
           |||  /__________\
ART
}

run_tree_grow_animation() {
    tput civis 2>/dev/null || true
    local stages=(stage_1 stage_2 stage_3 stage_4 stage_5 stage_6 stage_7 stage_8)
    local idx=0

    while kill -0 "$BG_PID" 2>/dev/null; do
        clear
        echo -e "${CYAN}================================================================${NC}"
        echo -e "${GREEN}${BOLD}             TREE SECURITY - GERMINATING & SPROUTING            ${NC}"
        echo -e "${CYAN}================================================================${NC}\n"
        echo -e "${GREEN}"
        ${stages[$idx]}
        echo -e "${NC}"
        
        # Advance through stages, then pulse between the last two when mature
        if [ $idx -lt 7 ]; then
            idx=$((idx + 1))
        else
            idx=6
        fi
        sleep 0.65
    done

    tput cnorm 2>/dev/null || true
    clear
    wait "$BG_PID"
    return $?
}

run_simple_animation() {
    local title="$1"
    shift
    local stages=("$@")
    local idx=0

    tput civis 2>/dev/null || true
    while kill -0 "$BG_PID" 2>/dev/null; do
        clear
        echo -e "${CYAN}================================================================${NC}"
        echo -e "${GREEN}${BOLD}             TREE SECURITY - ${title}            ${NC}"
        echo -e "${CYAN}================================================================${NC}\n"
        echo -e "${GREEN}"
        ${stages[$idx]}
        echo -e "${NC}"
        idx=$(( (idx + 1) % ${#stages[@]} ))
        sleep 0.5
    done
    tput cnorm 2>/dev/null || true
    clear
    wait "$BG_PID"
    return $?
}

# ==============================================================================
# WORKERS
# ==============================================================================

do_install() {
    echo "[*] Starting installation routine..." > "$LOG_FILE"

    CORE_PKGS=(
        nmap
        netdiscover
        exploitdb
        python3
        python3-pip
        python3-dev
        build-essential
        libxml2-dev
        libxslt1-dev
        libjpeg-dev
        zlib1g-dev
        libfreetype6-dev
        libcairo2
        libpango-1.0-0
        libpangocairo-1.0-0
        fonts-dejavu-core
    )

    apt-get update -y >> "$LOG_FILE" 2>&1

    for pkg in "${CORE_PKGS[@]}"; do
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
            apt-get install -y --no-install-recommends "$pkg" >> "$LOG_FILE" 2>&1
        fi
    done

    python3 -m pip install \
        "rich>=13.7.0" \
        "beautifulsoup4>=4.12.0" \
        "requests>=2.31.0" \
        "xhtml2pdf>=0.2.16" \
        "markdown>=3.6" \
        "python-nmap>=0.7.1" \
        "pillow>=10.2.0" \
        "reportlab>=4.1.0" \
        --break-system-packages >> "$LOG_FILE" 2>&1 || true

    # Make target python executable
    chmod +x "$SCRIPT_DIR/tree"

    # Reliable dual wrapper registration using printf to avoid shell escaping bugs
    printf '#!/usr/bin/env bash\nexec python3 "%s/tree" "$@"\n' "$SCRIPT_DIR" > /usr/bin/tree-sec
    chmod +x /usr/bin/tree-sec
    cp -f /usr/bin/tree-sec /usr/local/bin/tree-sec 2>/dev/null || true

    # Force IPv4 resolution speedup in gai.conf
    if ! grep -q "precedence ::ffff:0:0/96 100" /etc/gai.conf 2>/dev/null; then
        echo "precedence ::ffff:0:0/96 100" >> /etc/gai.conf
    fi

    hash -r 2>/dev/null || true
    echo "[+] Installation complete." >> "$LOG_FILE"
}

do_update() {
    echo "[*] Updating repository..." > "$LOG_FILE"
    cd "$SCRIPT_DIR"
    git pull origin main >> "$LOG_FILE" 2>&1
    do_install
    echo "[+] Update complete." >> "$LOG_FILE"
}

do_remove() {
    echo "[*] Removing global links and wrappers..." > "$LOG_FILE"
    rm -f /usr/bin/tree-sec /usr/local/bin/tree-sec
    hash -r 2>/dev/null || true
    echo "[+] Removal complete." >> "$LOG_FILE"
}

# ==============================================================================
# MENU
# ==============================================================================

clear
echo -e "${GREEN}${BOLD}"
cat << "BANNER"
  ████████╗██████╗ ███████╗███████╗
  ╚══██╔══╝██╔══██╗██╔════╝██╔════╝
     ██║   ██████╔╝█████╗  █████╗  
     ██║   ██╔══██╗██╔══╝  ██╔══╝  
     ██║   ██║  ██║███████╗███████╗
     ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝
BANNER
echo -e "${NC}"
echo -e "${CYAN}Multi-Provider AI Penetration Testing & Reconnaissance Framework${NC}\n"

echo -e "Choose an operation:"
echo -e "  ${GREEN}[1]${NC} Install TREE (Setup dependencies, graphics & global paths)"
echo -e "  ${BLUE}[2]${NC} Update TREE (Inspect changelog & apply latest features)"
echo -e "  ${RED}[3]${NC} Remove TREE (Uninstall global binary & shell integrations)"
echo -e "  ${YELLOW}[4]${NC} Exit"
echo ""

read -p "Select [1-4]: " OPTION

case "$OPTION" in
    1)
        do_install &
        BG_PID=$!
        run_tree_grow_animation
        
        if [ $? -eq 0 ]; then
            clear
            echo -e "${GREEN}${BOLD}"
            stage_8
            echo -e "${NC}"
            echo -e "${CYAN}================================================================${NC}"
            echo -e "${GREEN}${BOLD}           🌲 TREE FRAMEWORK SUCCESSFULLY INSTALLED 🌲          ${NC}"
            echo -e "${CYAN}================================================================${NC}"
            echo -e ""
            echo -e "${BOLD}HOW TO START AND USE THE TOOL:${NC}"
            echo -e ""
            echo -e "  1. Open a terminal anywhere and run:"
            echo -e "     ${YELLOW}${BOLD}sudo tree-sec${NC}"
            echo -e ""
            echo -e "  2. On first run, select your preferred AI service:"
            echo -e "     ${CYAN}• Google Gemini${NC} (Free / recommended)"
            echo -e "     ${CYAN}• OpenAI (ChatGPT)${NC}"
            echo -e "     ${CYAN}• Anthropic (Claude)${NC}"
            echo -e "     ${CYAN}• OpenRouter${NC}"
            echo -e ""
            echo -e "  3. Basic commands inside the console:"
            echo -e "     ${GREEN}tree >${NC} ${BOLD}netscan${NC}               (Discover live hosts & OS signatures)"
            echo -e "     ${GREEN}tree >${NC} ${BOLD}select 0${NC}              (Lock target to device #0)"
            echo -e "     ${GREEN}tree >${NC} ${BOLD}scan${NC}                  (Run full recon & Exploit-DB check)"
            echo -e "     ${GREEN}tree >${NC} ${BOLD}analyze${NC}               (Stream AI vulnerability triage)"
            echo -e "     ${GREEN}tree >${NC} ${BOLD}export report.pdf${NC}     (Generate styled audit PDF)"
            echo -e "${CYAN}================================================================${NC}\n"
        else
            echo -e "${RED}[-] Installation encountered errors. Check log: ${LOG_FILE}${NC}"
            exit 1
        fi
        ;;

    2)
        if [ ! -f "/usr/bin/tree-sec" ] && ! command -v tree-sec &>/dev/null; then
            echo -e "\n${RED}[-] TREE is not installed on this system.${NC}"
            echo -e "${YELLOW}[!] Please run install first (Option 1).${NC}\n"
            exit 1
        fi

        echo -e "\n${BLUE}[*] Checking for updates from origin/main...${NC}"
        cd "$SCRIPT_DIR"
        git fetch origin main >/dev/null 2>&1 || {
            echo -e "${RED}[-] Could not reach GitHub. Check network connectivity.${NC}"
            exit 1
        }

        LOCAL_HASH=$(git rev-parse HEAD)
        REMOTE_HASH=$(git rev-parse origin/main)

        if [ "$LOCAL_HASH" = "$REMOTE_HASH" ]; then
            echo -e "${GREEN}[✓] TREE is already up to date! (Commit: ${LOCAL_HASH:0:7})${NC}\n"
            exit 0
        fi

        NEW_COMMITS_COUNT=$(git rev-list --count HEAD..origin/main)
        echo -e "\n${CYAN}================================================================${NC}"
        echo -e "${GREEN}${BOLD}             WHAT'S NEW (${NEW_COMMITS_COUNT} Incoming Commits)             ${NC}"
        echo -e "${CYAN}================================================================${NC}"
        git log --color=always --pretty=format:"  ${YELLOW}%h${NC} - ${GREEN}%s${NC} ${BLUE}(%cr)${NC}" HEAD..origin/main
        echo ""
        echo -e "\n${BOLD}Modified Files:${NC}"
        git diff --stat --color=always HEAD..origin/main | sed 's/^/  /'
        echo -e "${CYAN}================================================================${NC}\n"

        read -p "Apply these updates now? [Y/n]: " CONFIRM
        CONFIRM=${CONFIRM:-Y}
        if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}[*] Update aborted.${NC}\n"
            exit 0
        fi

        do_update &
        BG_PID=$!
        run_simple_animation "PRUNING & GROOMING" groom_1 groom_2 groom_3 groom_4

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}${BOLD}[+] TREE has been groomed and updated to the latest version!${NC}"
            echo -e "${CYAN}[*] Launch anytime with: ${BOLD}sudo tree-sec${NC}\n"
        else
            echo -e "${RED}[-] Update failed. Check log: ${LOG_FILE}${NC}"
            exit 1
        fi
        ;;

    3)
        echo -e "\n${YELLOW}[!] Warning: This will remove the global tree-sec command.${NC}"
        read -p "Are you sure you want to proceed? [y/N]: " CONFIRM
        if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}[*] Removal cancelled.${NC}\n"
            exit 0
        fi

        do_remove &
        BG_PID=$!
        run_simple_animation "CHOPPING & CLEARING" chop_1 chop_2 chop_3 chop_4

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[+] TREE binaries and global links removed successfully.${NC}\n"
        else
            echo -e "${RED}[-] Removal encountered an issue. Check log: ${LOG_FILE}${NC}"
            exit 1
        fi
        ;;

    4)
        echo -e "${BLUE}[*] Exiting installer.${NC}\n"
        exit 0
        ;;

    *)
        echo -e "${RED}[-] Invalid option.${NC}\n"
        exit 1
        ;;
esac
