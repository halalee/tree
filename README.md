# TREE Framework 🌲

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform: Kali Linux](https://img.shields.io/badge/Platform-Kali%20Linux%20%7C%20Debian%20%7C%20WSL-blue.svg)](https://www.kali.org)
[![Python: 3.10+](https://img.shields.io/badge/Python-3.10+-yellow.svg)](https://www.python.org)
[![Multi-AI: Gemini | OpenAI | Claude | OpenRouter](https://img.shields.io/badge/AI-Multi--Provider%20Supported-purple.svg)](https://github.com/halalee/tree)

> **TREE** is an automated penetration testing, reconnaissance, and vulnerability triage framework built for Kali Linux, Debian systems, and WSL environments. It couples dual-layer host discovery and automated service fingerprinting with an encrypted multi-provider AI reasoning engine (Gemini, OpenAI, Claude, OpenRouter) and styled executive PDF reporting.

---

## ⚡ Key Highlights

* **Multi-Provider AI Architecture:** Choose and switch between Google Gemini, OpenAI (ChatGPT), Anthropic (Claude), and OpenRouter on the fly.
* **Encrypted API Vault at Rest:** Named API keys are encrypted at rest using host-specific cryptographic derivation (keyed to machine identity and user salt). Keys are never stored in plaintext, preventing unauthorized credential theft.
* **Proactive Live Health Probes:** Validates keys against provider REST APIs live during entry and automatically checks the active key on every console startup.
* **Dual-Layer Host & OS Fingerprinting:** Scans local subnets via rapid ARP sweeps (`netdiscover`) followed by targeted Nmap OS detection (`-O -F --osscan-limit --max-os-tries 1`).
* **Multi-Tier Reconnaissance:** Automated TCP port sweeps, service banner correlation, local Exploit-DB searches (`searchsploit`), anonymous FTP testing, OpenSSH CVE checks (e.g., regreSSHion), and web crawler checks.
* **Universal Global Execution:** Zero-configuration execution via `/usr/bin/tree-sec` and `/usr/local/bin/tree-sec` allowing launch from any working directory without path collisions.
* **WSL & Minimal Distro Ready:** Automatically packages missing C/C++ rendering and font libraries (`libcairo2`, `libpango`, `fonts-dejavu-core`) to ensure `xhtml2pdf` runs reliably inside Windows Store Kali WSL instances.
* **Deep Terminal Animations:** 8-stage visual tree germination sequence (soil prep $\rightarrow$ seed $\rightarrow$ roots $\rightarrow$ sprout $\rightarrow$ sapling $\rightarrow$ mature pine), pruning update animations, and chop-down uninstallation.

---

## 🛠️ Architecture Overview

tree/
├── tree                      # Interactive CLI shell, vault manager & command dispatcher
├── install.sh                # Lifecycle manager (8-stage animation, dependency linker)
├── requirements.txt          # Python dependencies
└── core/
├── scanner.py            # LocalNetworkScanner, ReconScanner, Exploit-DB & WebAuditor
├── ai_engine.py          # Unified multi-provider streaming client (Gemini/OpenAI/Claude/OpenRouter)
└── pdf_generator.py      # Unicode sanitizer & XHTML-to-PDF report generator


---

## 🚀 Installation & First Run

### 1. Clone the Repository
```bash
git clone [https://github.com/halalee/tree.git](https://github.com/halalee/tree.git)
cd tree

2. Run the Installer
Bash

sudo ./install.sh

Choose [1] Install TREE. The installer runs the 8-stage tree germination animation while handling:

    System packages (nmap, netdiscover, exploitdb, build-essential, libcairo2, libpango-1.0-0, etc.).

    Python dependencies (rich, beautifulsoup4, xhtml2pdf, reportlab, requests, etc.).

    Global path registration into /usr/bin/tree-sec and /usr/local/bin/tree-sec.

    Network IPv4 DNS precedence optimization in /etc/gai.conf.

3. Launch from Any Directory
Bash

sudo tree-sec

On first launch, you are prompted to select your preferred AI service (Gemini, ChatGPT, Claude, or OpenRouter), assign a friendly alias, and enter the key. The key is verified live and saved to the encrypted vault.
💻 CLI Commands & Workflow
Command	Description
netscan	Sweep local subnet with ARP discovery and active OS detection.
select <id>	Lock active target to a discovered device index from the table.
set target <ip>	Manually specify a target IP or hostname.
scan	Run port scanning, banner grabbing, Exploit-DB, and web audits.
analyze	Stream vulnerability triage live using the active AI provider.
report	Render the latest markdown assessment report in terminal.
export [file.pdf]	Compile and export the assessment report into a styled PDF.
key list	List all saved API keys, providers, and encrypted vault values.
key add	Add, validate, and encrypt a new named API key into the vault.
key switch <name>	Change the active AI engine/key instantly.
key remove <name>	Delete an API key securely from the encrypted storage.
show options	Display active target, provider, and in-memory key state.
clear	Clear the terminal display.
exit / quit	Exit the Tree console.
Typical Assessment Flow
Plaintext

tree (no target) > netscan
# Discovers live devices with IP, MAC, Vendor, and OS signatures

tree (no target) > select 1
# Targets selected machine (e.g., 192.168.1.45)

tree (192.168.1.45) > scan
# Executes 3-tier recon pipeline and queries local searchsploit

tree (192.168.1.45) > analyze
# Streams prioritized security findings and mitigations to the console

tree (192.168.1.45) > export audit_report.pdf
# Generates a styled executive PDF deliverable

📝 Maintenance & Release Changelog
Version 2.4.0

    Multi-Provider AI Engine:

        Added unified SSE streaming support in core/ai_engine.py for Google Gemini, OpenAI (ChatGPT), Anthropic (Claude), and OpenRouter.

    Host-Derived Encrypted Key Vault:

        Implemented machine-keyed XOR/Fernet style encryption at rest for API keys in ~/.tree_config.json.

        Added key list, key add, key switch, and key remove management commands directly inside the interactive console.

    Proactive Key Validation:

        Live health check endpoints ping provider APIs during key registration and on every console launch.

    Global Path & Wrapper Hardening:

        Replaced heredocs with safe printf wrappers in install.sh to prevent Zsh history expansion syntax errors (zsh: event not found).

        Dual-registered wrappers in /usr/bin/tree-sec and /usr/local/bin/tree-sec for universal access.

Version 2.3.0

    Lifecycle Visuals & Usability:

        Expanded install animation to an 8-stage tree germination progression (soil preparation, seed, roots, sprout, sapling, branching, mature pine).

        Added post-install guidance card showing immediate next steps and basic commands.

    WSL Graphics & PDF Fixes:

        Bundled libcairo2, libpango-1.0-0, libjpeg-dev, and fonts-dejavu-core into install.sh to resolve xhtml2pdf font rendering failures on Kali WSL.

    Pre-Update Diff Inspector:

        install.sh Option 2 previews incoming commit messages, authors, relative timestamps, and diff statistics before applying updates.

Version 2.2.0

    OS Fingerprinting:

        Integrated fast Nmap OS sweeps (-O -F --osscan-limit --max-os-tries 1) into LocalNetworkScanner and added an OS Detection column to the Rich host table.

    Gemini Model Failover Chain:

        Added automated model fallback (gemini-flash-latest → gemini-2.5-flash-lite → gemini-3.5-flash → gemini-2.5-flash) for handling API rate limits and HTTP 503 capacity spikes.

📄 License

Distributed under the MIT License. See LICENSE for details.
