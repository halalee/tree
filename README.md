# TREE Framework 🌲 v2.4.0

**Automated AI-powered penetration testing, reconnaissance, and vulnerability triage console.** TREE Framework combines native Linux automation with real-time token streaming across Google Gemini, OpenAI, Anthropic Claude, and OpenRouter inside an interactive, unified cybersecurity console.

## 🎯 Key Features

* **Automated Reconnaissance Engine**

  * Local subnet discovery via ARP sweep (`netdiscover`)

  * Active OS fingerprinting using fast Nmap sweeps (`-O -F --osscan-limit --max-os-tries 1`)

  * Multi-phase TCP port and service version scanning

  * Local Exploit-DB correlation against detected service banners (`searchsploit`)

  * Automated anonymous FTP inspection and OpenSSH CVE banner auditing

  * HTTP/HTTPS web application endpoint and header auditing

* **Multi-Provider AI Streaming Core**

  * Direct REST SSE streaming across 4 major providers: **Google Gemini**, **OpenAI (ChatGPT)**, **Anthropic (Claude)**, and **OpenRouter**

  * Zero heavy vendor SDK dependencies (pure lightweight HTTP/SSE streaming)

  * Automatic multi-model fallback chain for Gemini to gracefully bypass rate limits and HTTP 503 capacity spikes

  * Real-time token delivery streaming vulnerability findings directly to your terminal

* **Encrypted Key Vault at Rest**

  * Machine-identity bound key encryption at rest derived from `/etc/machine-id` and user salt

  * Secure credential storage at `~/.tree_config.json` (`/root/.tree_config.json` under `sudo`) with `0600` permissions

  * In-memory only decryption during API requests (no plaintext keys written to disk)

  * Interactive key management (`key list`, `key add`, `key switch`, `key remove`)

* **Proactive Key Health Verification**

  * Live probe requests test API keys against provider servers during input

  * Automatic background key health verification on every startup

* **Non-Blocking Background Update Checks**

  * Background Git thread silently checks upstream releases on GitHub during console launch

  * Notifies you if updates are ready without delaying startup or interrupting commands

* **Executive PDF Deliverables**

  * Professional color-styled security audit reports compiled via `xhtml2pdf`

  * Sanitized Unicode/UTF-8 handling to prevent layout and font rendering crashes

* **Global CLI Access**

  * Dual global system wrappers installed at `/usr/bin/tree-sec` and `/usr/local/bin/tree-sec`

  * Executable from any directory: `sudo tree-sec`

## 🏗️ Architecture & Directory Structure

```
tree-framework/
├── tree                      # Interactive CLI shell, vault manager & command dispatcher
├── install.sh                # 8-stage lifecycle manager & global path linker
├── requirements.txt          # Python dependencies
└── core/
    ├── scanner.py            # LocalNetworkScanner, ReconScanner, ExploitDBCorrelator, ServiceAuditor, WebAuditor
    ├── ai_engine.py          # Unified multi-provider REST SSE streaming engine
    └── pdf_generator.py      # Unicode sanitizer & XHTML-to-PDF report generator

```

## 🚀 Installation & Setup

### Prerequisites

* **OS:** Kali Linux, Debian, Ubuntu, or WSL2 (Debian/Ubuntu)

* **Python:** 3.10 or later

* **Tools:** `nmap`, `netdiscover`, `exploitdb` (automatically configured by installer)

* **Privileges:** Root privileges (`sudo`) required for raw socket access and ARP discovery

### Installation

```
# 1. Clone repository
git clone https://github.com/halalee/tree.git
cd tree

# 2. Run the interactive installer
sudo ./install.sh

```

Select **`[1] Install TREE`** from the menu. The installer executes an 8-stage ASCII tree germination animation while handling:

1. Native system packages (`nmap`, `netdiscover`, `exploitdb`, `build-essential`).

2. WSL/Debian graphics libraries (`libcairo2`, `libpango-1.0-0`, `fonts-dejavu-core`) to guarantee PDF generation reliability.

3. Python libraries (`rich`, `requests`, `xhtml2pdf`, `markdown`, `python-nmap`, `pillow`, `reportlab`).

4. Dual global binary registration into `/usr/bin/tree-sec` and `/usr/local/bin/tree-sec`.

5. IPv4 DNS precedence optimization in `/etc/gai.conf` to eliminate API lookup latency.

## 🔄 Assessment Workflow & How It Works

Launch the console globally from any directory:

```
sudo tree-sec

```

On your first run, TREE prompts you to select your preferred default AI provider, give the key an alias name, and enter the key. Once verified, the interactive shell starts:

```
tree (no target) > netscan

```

* **Discovery:** Sweeps your local subnet using ARP, extracts active MAC addresses, queries vendor OUIs, and executes active Nmap OS detection.

```
tree (no target) > select 0

```

* **Target Selection:** Binds target to device index `0` (e.g., `192.168.1.50`). You can also manually set targets with `set target <ip/hostname>`.

```
tree (192.168.1.50) > scan

```

* **Comprehensive Reconnaissance:** Runs a 3-tier pipeline:

  1. Fast TCP port sweep.

  2. Nmap service banner and version identification.

  3. Local Exploit-DB matching via `searchsploit`, anonymous FTP verification, OpenSSH CVE banner auditing, and web server inspection.

```
tree (192.168.1.50) > analyze

```

* **AI-Powered Triage:** Streams an executive markdown assessment report directly into your terminal in real-time, detailing attack surfaces, CVSS risk ratings, and prioritized remediation steps.

```
tree (192.168.1.50) > export audit_report.pdf

```

* **Report Deliverable:** Compiles the findings into a color-highlighted PDF deliverable.

## 📖 Command Reference

All commands are executed inside the interactive `tree` shell:

| **Command** | **Syntax** | **Description** | 
| **netscan** | `netscan` | Sweep connected subnet with visual ARP progress & OS detection | 
| **select** | `select <id>` | Select a discovered host ID as the active target | 
| **set target** | `set target <ip/host>` | Manually configure target IP or hostname | 
| **scan** | `scan` | Execute the 3-phase reconnaissance pipeline against the active target | 
| **analyze** | `analyze` | Stream real-time AI vulnerability triage via the active AI provider | 
| **report** | `report` | Display the latest generated audit report in the terminal | 
| **export** | `export [filename.pdf]` | Export the latest audit report to a styled PDF | 
| **key list** | `key list` | List all saved API keys, providers, and creation timestamps | 
| **key add** | `key add` | Interactively validate, encrypt, and save a new named AI API key | 
| **key switch** | `key switch <name>` | Switch active AI provider/key on the fly | 
| **key remove** | `key remove <name>` | Permanently remove a saved API key from the vault | 
| **show options** | `show options` | Display current configuration (target, provider, key status) | 
| **clear** | `clear` | Clear the terminal display | 
| **exit / quit** | `exit` | Exit the Tree console | 

## 🔐 Encrypted Key Vault

Credentials are saved in `~/.tree_config.json` (`/root/.tree_config.json` under `sudo`) with restricted `0600` permissions.

### Security Implementation

* **Machine Identity Binding:** Encryption keys are derived using SHA-256 over `/etc/machine-id` combined with the user salt.

* **Obfuscation at Rest:** Key values are encrypted and stored with an `enc:` prefix. Raw API keys cannot be read by simply inspecting the configuration file on another system.

* **Zero Plaintext Logs:** Decrypted keys exist only transiently in memory when issuing HTTPS calls to provider endpoints.

### Example Vault File (`~/.tree_config.json`)

```
{
  "active_key_name": "lab-gemini",
  "keys": {
    "lab-gemini": {
      "provider": "gemini",
      "encrypted_key": "enc:q8rR4vF...",
      "created_at": "2026-09-17 10:30"
    },
    "work-claude": {
      "provider": "claude",
      "encrypted_key": "enc:m2aK9vX...",
      "created_at": "2026-09-17 10:45"
    }
  }
}

```

## 📦 Dependencies

### System Packages

* `nmap` – Port scanning, banner grabbing, and OS detection

* `netdiscover` – Active ARP discovery sweeps

* `exploitdb` – Local vulnerability mapping (`searchsploit`)

* `libcairo2`, `libpango-1.0-0`, `fonts-dejavu-core` – PDF layout and font rendering engine

### Python Libraries

* `rich` – Terminal user interface, tables, and progress bars

* `requests` – Lightweight HTTP REST SSE client

* `xhtml2pdf` & `reportlab` – Styled PDF document compilation

* `markdown` – Markdown parser

* `beautifulsoup4` – Web crawler endpoint parsing

* `python-nmap` – Programmatic Nmap integration

* `pillow` – Image support for report rendering

## 📊 Maintenance & Release Changelog

### v2.4.0

* **Multi-Provider AI Core:** Unified SSE streaming support in `core/ai_engine.py` for Google Gemini, OpenAI (ChatGPT), Anthropic (Claude), and OpenRouter.

* **Encrypted Key Vault:** Machine-identity bound encryption at rest for API keys with `key list`, `key add`, `key switch`, and `key remove` management commands.

* **Proactive Key Validation:** Live endpoint health probes during key setup and background checks on console launch.

* **Non-Blocking Update Detector:** Background Git thread alerts users to new GitHub releases on launch without delaying the shell.

* **Safe Wrapper Registration:** Hardened global launcher scripts in `/usr/bin/tree-sec` and `/usr/local/bin/tree-sec` using safe `printf` templates to eliminate Zsh history expansion syntax errors.

### v2.3.0

* **Lifecycle Visuals & Usability:** Expanded install animation to an 8-stage tree germination progression and added post-install guidance summaries.

* **WSL Graphics & PDF Fixes:** Added `libcairo2`, `libpango-1.0-0`, `libjpeg-dev`, and `fonts-dejavu-core` to `install.sh` for reliable PDF generation on WSL2 Kali instances.

* **Interactive Update Inspector:** Option 2 in `install.sh` previews incoming commit logs, authors, and file diff statistics before applying updates.

### v2.2.0

* **OS Fingerprinting:** Integrated fast Nmap OS sweeps (`-O -F --osscan-limit --max-os-tries 1`) into `LocalNetworkScanner`.

* **Failover Resilience:** Model failover matrix (`gemini-flash-latest` → `gemini-2.5-flash-lite` → `gemini-3.5-flash`) for handling API rate limits.

## 📄 License

Distributed under the MIT License. See `LICENSE` for details.