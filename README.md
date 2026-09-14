# TREE - AI-Powered Penetration Testing & Vulnerability Assessment Console

TREE is an interactive security console inspired by `msfconsole`. It combines automated local and remote reconnaissance (Nmap, Netdiscover, Web analysis) with Google Gemini AI models to perform risk triaging, threat vector analysis, and defensive remediation reporting with color-coded PDF generation.

---

## Features

- **Interactive Shell**: Metasploit-style interface (`tree >`) with familiar commands.
- **Local Network Discovery**: Integrated `netdiscover` ARP sweeps to discover live subnet hosts.
- **Target Enumeration**: Fast port probing and Nmap service banner extraction (`-sV`).
- **AI Vulnerability Triaging**: Context-aware risk scoring (Critical/High/Medium/Low) and attack-vector explanation using the Gemini API.
- **Color-Coded PDF Reports**: One-command export to styled assessment reports (`export report.pdf`).

---

## Installation

Clone the repository and run the automated installer:

```bash
git clone [https://github.com/](https://github.com/)<your-username>/tree-framework.git
cd tree-framework
sudo chmod +x install.sh
sudo ./install.sh
