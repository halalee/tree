# TREE Framework 🌲

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform: Kali Linux](https://img.shields.io/badge/Platform-Kali%20Linux%20%7C%20Debian%20%7C%20WSL-blue.svg)](https://www.kali.org)
[![Python: 3.10+](https://img.shields.io/badge/Python-3.10+-yellow.svg)](https://www.python.org)
[![AI Engine: Gemini Flash](https://img.shields.io/badge/AI-Google%20Gemini%20Flash-orange.svg)](https://aistudio.google.com)

> **TREE** is an automated penetration testing, reconnaissance, and vulnerability triage console built natively for Kali Linux and Debian-based systems. It automates local subnet discovery, multi-stage port and service enumeration, local Exploit-DB correlation, and real-time AI-powered risk assessment with executive PDF reporting.

---

## ⚠️ Legal Disclaimer & Warning Notice

> **IMPORTANT NOTICE — AUTHORIZED USE ONLY**
> 
> The **TREE Framework** is developed and distributed exclusively for authorized penetration testing, educational cybersecurity research, academic demonstration, and defensive system hardening.
> 
> * **Authorization Requirement:** You must obtain prior written consent from the target infrastructure owner before performing any active scanning, host discovery, or service enumeration with this tool.
> * **Prohibition of Malicious Use:** Executing network scans or vulnerability assessments against unauthorized systems, networks, or endpoints is illegal and violates local, national, and international cybersecurity laws (including the Indian Information Technology Act, the US Computer Fraud and Abuse Act, and equivalent statutes).
> * **Limitation of Liability:** The author(s), developers, and contributors accept no responsibility or liability for any misuse, damage, data corruption, network disruption, legal ramifications, or collateral issues caused by the application or misapplication of this software. By cloning, compiling, or executing this tool, you assume full responsibility for your actions.

---

## ⚡ Key Features

* **Interactive Rich CLI Console:** Modular command-driven terminal environment (`tree-sec`) with real-time spinners, status tables, and colorized outputs.
* **Dual-Layer Host Discovery:** Combines ARP subnet sweeps (`netdiscover`) with targeted active OS fingerprinting (`nmap -O`).
* **Multi-Stage Service Auditing:** Automatic version extraction, anonymous FTP inspection, OpenSSH CVE checks (e.g., regreSSHion), and web application endpoint crawling.
* **Exploit-DB Integration:** Automatically correlates identified services and version banners against local `searchsploit` databases.
* **Resilient AI Triage Streaming:** Streams executive audit reports token-by-token using Gemini Flash with an automatic fallback matrix to handle 503/429 capacity spikes.
* **Real-Time Key Validation:** Live endpoint health probes prevent saving invalid API keys during setup and automatically verify keys on every startup.
* **Executive Deliverables:** Generates color-badged, UTF-8 clean PDF audit reports styled for clients and assessment reviews.
* **Animated Lifecycle Management:** Full ASCII terminal animations for installation (sprouting seed), updates (tree grooming), and removal (chopping).

---

## 🛠️ Architecture Overview

```text
tree/
├── tree                      # Main interactive CLI shell & command dispatcher
├── install.sh                # Lifecycle manager (Install, Update, Remove)
├── requirements.txt          # Python dependencies
└── core/
    ├── scanner.py            # Reconnaissance, Nmap, Exploit-DB & web auditor
    ├── ai_engine.py          # Gemini REST client, model fallback & SSE streaming
    └── pdf_generator.py      # Unicode sanitizer & XHTML-to-PDF compiler
```

---

## 🚀 Quick Start & Installation

### 1. Clone the Repository
```bash
git clone [https://github.com/halalee/tree.git](https://github.com/halalee/tree.git)
cd tree
```

### 2. Run the Lifecycle Installer
```bash
sudo ./install.sh
```

Select **`[1] Install TREE`** from the interactive menu. The installer will:
* Detect missing native C/graphics libraries (supporting bare-metal, VMs, and WSL environments).
* Install required system packages (`nmap`, `netdiscover`, `exploitdb`, `libcairo2`, etc.).
* Configure Python packages bypassing PEP 668 constraints.
* Force IPv4 DNS precedence in `/etc/gai.conf` to eliminate resolution delays.
* Register the global wrapper `sudo tree-sec`.

---

## 💻 Usage Workflow

Launch the console from any directory:

```bash
sudo tree-sec
```

### Typical Assessment Flow

```text
tree (no target) > netscan
# Sweeps the subnet, identifies active devices, and displays IP, MAC, Vendor, and OS

tree (no target) > select 1
# Locks target to the chosen device index (e.g., 192.168.1.34)

tree (192.168.1.34) > scan
# Performs fast TCP sweep, service version grabs, Exploit-DB mapping, and web audits

tree (192.168.1.34) > analyze
# Streams live AI risk assessment and prioritized hardening steps directly to the screen

tree (192.168.1.34) > export audit_report.pdf
# Compiles the triage into a branded, executive-ready PDF deliverable
```

### Available Commands

| Command | Description |
| :--- | :--- |
| `netscan` | Scan local connected subnet with visual ARP progress & OS detection. |
| `select <id>` | Select a discovered host from the table as the active target. |
| `set target <ip>` | Manually specify a target IP or hostname. |
| `set api_key <key>` | Validate and store a new Google Gemini API key. |
| `show options` | Display current active target and masked API key status. |
| `scan` | Execute the full multi-phase reconnaissance pipeline on the target. |
| `analyze` | Stream Gemini AI vulnerability triage with live terminal output. |
| `report` | Render the last generated markdown report in the console. |
| `export [file.pdf]`| Compile and export the assessment to a color-highlighted PDF. |
| `clear` | Clear the terminal display. |
| `exit` / `quit` | Exit the Tree console. |

---

## 📝 Update & Maintenance Changelog

### Version 2.2.0
* **Live API Key Validation:**
  * Added proactive Google Gemini REST API probes during first-time key setup.
  * Added background key verification on every console startup.
  * Implemented validation for manual key updates via `set api_key <key>`.
* **WSL / Minimal VM Compatibility:**
  * Added native dependencies (`libcairo2`, `libpango-1.0-0`, `libjpeg-dev`, `fonts-dejavu-core`) to `install.sh` to resolve `xhtml2pdf` rendering crashes in Microsoft Store Kali WSL instances.
* **Interactive Update Changelog:**
  * Option 2 (`Update TREE`) in `install.sh` now fetches and previews incoming commit messages, authors, timestamps, and diff statistics before prompting to apply updates.

### Version 2.1.0
* **Active OS Detection in `netscan`:**
  * Integrated fast Nmap OS fingerprinting (`-O -F --osscan-limit --max-os-tries 1`) into `LocalNetworkScanner`.
  * Added an **OS Detection** column to the Rich host discovery table.
* **AI Engine Resilience & Fallback Matrix:**
  * Implemented an automated failover chain (`gemini-flash-latest` -> `gemini-2.5-flash-lite` -> `gemini-3.5-flash` -> `gemini-2.5-flash`) to gracefully bypass Google API 503/429 capacity spikes.
  * Fixed unhandled `requests.exceptions.RequestException` and DNS resolution timeout bugs in `tree`.
* **Installer Optimization:**
  * Replaced unconditional package re-installations with `dpkg -s` checks, eliminating multi-gigabyte Exploit-DB re-downloads and slashing install times.

### Version 2.0.0
* **Core Architecture Overhaul:**
  * Modularized scanner into discrete components: `ReconScanner`, `ExploitDBCorrelator`, `ServiceAuditor`, and `WebAuditor`.
  * Built SSE streaming REST client for Gemini in `core/ai_engine.py`.
  * Added Unicode-sanitized PDF compiler using `xhtml2pdf` in `core/pdf_generator.py`.
* **Terminal Experience:**
  * Added animated ASCII art sequences for installation, update, and removal routines.

---

## ⚖️ License & Intellectual Property

This software is released under the **MIT License**.

```text
MIT License

Copyright (c) 2026 Muhammed Rayyan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
