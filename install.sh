#!/usr/bin/env bash
# ==========================================================
# TREE Framework - Unified Lifecycle Manager (Install/Update/Remove)
# Full Terminal Animated Loading Screens
# ==========================================================

LOG_FILE="/tmp/tree_lifecycle.log"
rm -f "$LOG_FILE"
touch "$LOG_FILE"

# Colors
GREEN="\033[0;32m"
CYAN="\033[0;36m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
BROWN="\033[0;33m"
RED="\033[0;31m"
BOLD="\033[1m"
NC="\033[0m"

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[-] Please run this script with sudo or as root.${NC}"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Trap exits to restore cursor
trap 'tput cnorm; echo -e "\n${RED}[!] Process interrupted.${NC}"; exit 1' INT TERM
cleanup() {
    tput cnorm
}
trap cleanup EXIT

# ==========================================================
# ANIMATION ENGINES
# ==========================================================

# 1. Big Growth Animation (Install)
grow_stage_1() {
cat << "EOF"
             .--.
          .-(    ).
         (___.__)__)   ☁️
           : : : :     🌧️
           : : : :
              
              .
            ( • )
    =========================
EOF
}

grow_stage_2() {
cat << "EOF"
             .--.
          .-(    ).
         (___.__)__)   ☁️
           : : : :     🌧️
           : : : :

             \|/
            --*--  🌱
              |
    =========================
EOF
}

grow_stage_3() {
cat << "EOF"
             .--.
          .-(    ).
         (___.__)__)   ☁️
           : : : :     🌧️
           : : : :
            \ | /
             \|/
             /|\
            / | \
              |
              |
    =========================
EOF
}

grow_stage_4() {
cat << "EOF"
              &&&
            &&&&&&&
          &&&  |  &&&
           &&  |  &&
             \ | /
              \|/
               |
               |
               |
    =========================
EOF
}

grow_stage_5() {
cat << "EOF"
           ,@@@@@@@@,
         ,@@@@@@@@@@@@,
       ,@@@@@@@|@@@@@@@@,
      &&&&&&&&&|&&&&&&&&&&
       &&&&&&&&|/&&&&&&&&
          {   |   }
           \  |  /
            \ | /
              |
              |
              |
    =========================
EOF
}

grow_stage_6() {
cat << "EOF"
          ,@@@@@@@@@@,
       ,,@@@@@@@@@@@@@@,,
      &&&%#%#%&|&%#%#%&&&
     &&%#%#%#%&|&%#%#%#%&&
    &&%#%#%#%#&|&%#%#%#%#&&
      &&&%#%#%&|/&%#%#%&&
          {   |   }
           \  |  /
            \ | /
              |
              |
              |
    =========================
EOF
}

# 2. Big Grooming Animation (Update)
groom_stage_1() {
cat << "EOF"
       ✂️
          ,@@@@@@@@@@,
       ,,@@@@@@@@@@@@@@,,
      &&&%#%#%&|&%#%#%&&&
     &&%#%#%#%&|&%#%#%#%&&
    &&%#%#%#%#&|&%#%#%#%#&&
      &&&%#%#%&|/&%#%#%&&
          {   |   }
            \ | /
              |
              |
    =========================
EOF
}

groom_stage_2() {
cat << "EOF"
                 ✂️
          ,@@@@@@@@@@,
       ,,@@@@@@@@@@@@@@,,
      &&&%#%#%&|&%#%#%&&&
     &&%#%#%#%&|&%#%#%#%&&  ✨
    &&%#%#%#%#&|&%#%#%#%#&&
      &&&%#%#%&|/&%#%#%&&
          {   |   }
            \ | /
              |
              |
    =========================
EOF
}

groom_stage_3() {
cat << "EOF"
          ,@@@@@@@@@@,     ✂️
       ,,@@@@@@@@@@@@@@,,
   ✨ &&&%#%#%&|&%#%#%&&&
     &&%#%#%#%&|&%#%#%#%&&
    &&%#%#%#%#&|&%#%#%#%#&&
      &&&%#%#%&|/&%#%#%&&
          {   |   }
            \ | /
              |
              |
    =========================
EOF
}

groom_stage_4() {
cat << "EOF"
          ,@@@@@@@@@@,
       ,,@@@@@@@@@@@@@@,,   ✨
      &&&%#%#%&|&%#%#%&&&
     &&%#%#%#%&|&%#%#%#%&&
    &&%#%#%#%#&|&%#%#%#%#&&
      &&&%#%#%&|/&%#%#%&&
          {   |   }
            \ | /
              |
              |
    =========================
EOF
}

# 3. Big Chopping / Removal Animation (Remove)
chop_stage_1() {
cat << "EOF"
          ,@@@@@@@@@@,
       ,,@@@@@@@@@@@@@@,,
      &&&%#%#%&|&%#%#%&&&
     &&%#%#%#%&|&%#%#%#%&&
    &&%#%#%#%#&|&%#%#%#%#&&
      &&&%#%#%&|/&%#%#%&&
          {   |   }
            \ | /
        🪓    |
              |
    =========================
EOF
}

chop_stage_2() {
cat << "EOF"
          ,@@@@@@@@@@,
       ,,@@@@@@@@@@@@@@,,
      &&&%#%#%&|&%#%#%&&&
     &&%#%#%#%&|&%#%#%#%&&
    &&%#%#%#%#&|&%#%#%#%#&&
      &&&%#%#%&|/&%#%#%&&
          {   |   }
            \ | /
           💥>|
              |
    =========================
EOF
}

chop_stage_3() {
cat << "EOF"
             ,@@@@@@@@@@,
          ,,@@@@@@@@@@@@@@,,
         &&&%#%#%&|&%#%#%&&& \
        &&%#%#%#%&|&%#%#%#%&& \
       &&%#%#%#%#&|&%#%#%#%#&& \
         &&&%#%#%&|/&%#%#%&&    \
             {   |   }           \
               \ | /              \
                 |                 \
                 |                  v
    =========================
EOF
}

chop_stage_4() {
cat << "EOF"
                             🍃
                                 🍂
                                     🪵

                 \ /
                --*-- (Stump)
                 / \
    =========================
EOF
}

# Runner to display animations while waiting for background jobs
run_animation() {
    local mode=$1
    local title=$2
    shift 2
    local stages=("$@")

    clear
    tput civis
    local idx=0
    local total=${#stages[@]}

    while kill -0 $BG_PID 2>/dev/null; do
        tput cup 0 0
        echo -e "${CYAN}================================================================${NC}"
        echo -e "${GREEN}             TREE FRAMEWORK - ${title}             ${NC}"
        echo -e "${CYAN}================================================================${NC}\n"

        ${stages[$idx]}

        echo -e "\n${YELLOW}[*] Working in background... Please wait.${NC}\n"
        idx=$(( (idx + 1) % total ))
        sleep 1.2
    done

    wait $BG_PID
    local exit_code=$?
    clear
    tput cnorm
    return $exit_code
}

# ==========================================================
# WORKER FUNCTIONS
# ==========================================================

do_install() {
    # 1. System packages (including graphics/fonts needed for WSL environments)
    WSL_AND_CORE_PKGS=(
        nmap
        netdiscover
        exploitdb
        python3
        python3-pip
        python3-bs4
        python3-markdown
        python3-requests
        build-essential
        libjpeg-dev
        zlib1g-dev
        libfreetype6-dev
        libcairo2
        libpango-1.0-0
        fonts-dejavu-core
    )

    apt-get update -y >> "$LOG_FILE" 2>&1
    apt-get install -y --no-install-recommends "${WSL_AND_CORE_PKGS[@]}" >> "$LOG_FILE" 2>&1

    # 2. Python packages
    python3 -m pip install \
        "rich>=13.7.0" \
        "beautifulsoup4>=4.12.0" \
        "requests>=2.31.0" \
        "xhtml2pdf>=0.2.16" \
        "markdown>=3.6" \
        "python-nmap>=0.7.1" \
        "google-genai>=0.1.1" \
        --break-system-packages >> "$LOG_FILE" 2>&1 || true

    # 3. Global wrappers
    chmod +x "$SCRIPT_DIR/tree"
    cat << EOF > /usr/local/bin/tree-sec
#!/usr/bin/env bash
exec python3 "$SCRIPT_DIR/tree" "\$@"
EOF
    chmod +x /usr/local/bin/tree-sec
    ln -sf /usr/local/bin/tree-sec /usr/bin/tree-sec

    # 4. Networking precedence
    if ! grep -q "precedence ::ffff:0:0/96 100" /etc/gai.conf 2>/dev/null; then
        echo "precedence ::ffff:0:0/96 100" >> /etc/gai.conf
    fi
}
do_update() {
    cd "$SCRIPT_DIR"
    git fetch origin main >> "$LOG_FILE" 2>&1
    git reset --hard origin/main >> "$LOG_FILE" 2>&1

    python3 -m pip install -r requirements.txt --break-system-packages --ignore-installed >> "$LOG_FILE" 2>&1 || true
    chmod +x "$SCRIPT_DIR/tree"
    ln -sf "$SCRIPT_DIR/tree" /usr/local/bin/tree-sec
    ln -sf "$SCRIPT_DIR/tree" /usr/bin/tree-sec
}

do_remove() {
    rm -f /usr/local/bin/tree-sec
    rm -f /usr/bin/tree-sec
    rm -f /root/.tree_config.json
    rm -f "$HOME/.tree_config.json"
    cd ..
    rm -rf tree
}

# ==========================================================
# INTERACTIVE CLI DISPATCHER
# ==========================================================

clear
echo -e "${GREEN}"
cat << "EOF"
  _______ _____  ______ ______ 
 |__   __|  __ \|  ____|  ____|
    | |  | |__) | |__  | |__   
    | |  |  _  /|  __| |  __|  
    | |  | | \ \| |____| |____ 
    |_|  |_|  \_\______|______|
  AI-Powered Penetration Testing
EOF
echo -e "${NC}"
echo -e "${CYAN}======================================================${NC}"
echo -e "${BOLD}Select an operation:${NC}"
echo -e "  ${GREEN}[1]${NC} ${BOLD}Install TREE${NC}   (Fresh system & dependency setup)"
echo -e "  ${YELLOW}[2]${NC} ${BOLD}Update TREE${NC}    (Compare with GitHub & sync changes)"
echo -e "  ${RED}[3]${NC} ${BOLD}Remove TREE${NC}    (Uninstall binaries, symlinks & configs)"
echo -e "  ${BLUE}[4]${NC} Exit"
echo -e "${CYAN}======================================================${NC}"
read -p "Enter choice [1-4]: " CHOICE

case "$CHOICE" in
    1)
        echo -e "\n${BLUE}[*] Initializing installation...${NC}"
        do_install &
        BG_PID=$!
        run_animation "INSTALL" "INSTALLING" grow_stage_1 grow_stage_2 grow_stage_3 grow_stage_4 grow_stage_5 grow_stage_6

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[+] TREE successfully installed!${NC}"
            echo -e "${CYAN}[*] Launch the console anytime with: ${YELLOW}sudo tree-sec${NC}\n"
        else
            echo -e "${RED}[-] Installation failed. Details in $LOG_FILE${NC}"
            exit 1
        fi
        ;;

    2)
        # 1. Check if installed
        if [ ! -f "/usr/local/bin/tree-sec" ] && ! command -v tree-sec &>/dev/null; then
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

        # 2. Extract and format what came new
        NEW_COMMITS_COUNT=$(git rev-list --count HEAD..origin/main)
        echo -e "\n${CYAN}======================================================${NC}"
        echo -e "${GREEN}${BOLD}             WHAT'S NEW (${NEW_COMMITS_COUNT} Incoming Commits)             ${NC}"
        echo -e "${CYAN}======================================================${NC}"
        
        # Display commit short hash, relative time, and commit message
        git log --color=always --pretty=format:"  ${YELLOW}%h${NC} - ${GREEN}%s${NC} ${BLUE}(%cr)${NC}" HEAD..origin/main
        echo ""

        # Display list of changed files with additions/deletions summary
        echo -e "\n${BOLD}Modified Files:${NC}"
        git diff --stat --color=always HEAD..origin/main | sed 's/^/  /'
        echo -e "${CYAN}======================================================${NC}\n"

        read -p "Apply these updates now? [Y/n]: " CONFIRM
        CONFIRM=${CONFIRM:-Y}
        if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}[*] Update aborted.${NC}\n"
            exit 0
        fi

        # 3. Proceed with grooming background update
        do_update &
        BG_PID=$!
        run_animation "UPDATE" "GROOMING & UPDATING" groom_stage_1 groom_stage_2 groom_stage_3 groom_stage_4

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[+] TREE has been groomed and updated to the latest version!${NC}\n"
        else
            echo -e "${RED}[-] Update failed. Check $LOG_FILE for details.${NC}"
            exit 1
        fi
        ;;
    3)
        if [ ! -f "/usr/local/bin/tree-sec" ] && ! command -v tree-sec &>/dev/null; then
            echo -e "\n${RED}[-] TREE is not currently installed on this system.${NC}\n"
            exit 0
        fi

        echo -e "\n${RED}[*] Cutting down and removing TREE...${NC}"
        do_remove &
        BG_PID=$!
        run_animation "REMOVE" "CHOPPING & REMOVING" chop_stage_1 chop_stage_2 chop_stage_3 chop_stage_4

        echo -e "${GREEN}[+] TREE has been completely removed from system PATH and binaries.${NC}"
        echo -e "${BLUE}[*] You can delete this source directory with: rm -rf $SCRIPT_DIR${NC}\n"
        ;;

    4)
        echo -e "\nExiting."
        exit 0
        ;;

    *)
        echo -e "\n${RED}[-] Invalid option selected.${NC}"
        exit 1
        ;;
esac
