# TREE Framework v2.4.0

![Platform](https://img.shields.io/badge/Platform-Kali%20%7C%20Debian%20%7C%20WSL-blueviolet)
![Python](https://img.shields.io/badge/Python-3.10+-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![AI-Powered](https://img.shields.io/badge/AI-Multi--Provider-orange)

**Automated AI-powered penetration testing, reconnaissance, and vulnerability triage console.** TREE Framework combines native Linux automation with real-time AI analysis across Google Gemini, OpenAI, Anthropic Claude, and OpenRouter for intelligent security assessments.

---

## 🎯 Key Features

- **Automated Reconnaissance Engine**
  - Subnet enumeration via ARP sweeps (`netdiscover`)
  - Active OS fingerprinting with Nmap (`-O -F` flags)
  - Multi-phase TCP service enumeration
  - Anonymous FTP/SSH credential testing
  - Web crawler integration for target discovery

- **Multi-Provider AI Core**
  - Real-time token streaming across 4 AI providers
  - Provider switching without workflow interruption
  - Seamless response aggregation for risk analysis
  - Context-aware vulnerability triage

- **Encrypted Key Vault**
  - Machine-identity bound encryption (salt: `/etc/machine-id`)
  - Secure credential storage at `~/.tree_config.json`
  - Runtime key management (`list`, `add`, `switch`, `remove`)
  - No plaintext keys on disk

- **Assessment Lifecycle**
  - 5-stage automated scanning pipeline
  - Non-blocking background update checks on startup
  - PDF report compilation via `xhtml2pdf`
  - Structured JSON export for CI/CD integration

- **Global CLI Access**
  - Single-command execution: `sudo tree-sec`
  - Native Linux path linking to `/usr/bin/tree-sec`
  - Daemon-compatible background operation

---

## 📋 Quick Start

```bash
# Install framework
git clone https://github.com/yourusername/tree-framework.git
cd tree-framework
sudo bash install.sh

# Initialize with AI provider
tree-sec key add --provider openai --key sk-xxx...

# Begin reconnaissance
sudo tree-sec netscan
```

---

## 🏗️ Architecture & Directory Structure

```
tree-framework/
├── install.sh                  # 8-stage installer with ASCII tree germination
├── tree_sec/
│   ├── __main__.py            # CLI entry point
│   ├── core/
│   │   ├── scanner.py         # Nmap & netdiscover orchestration
│   │   ├── analyzer.py        # AI triage engine (multi-provider)
│   │   └── reporter.py        # PDF/JSON export
│   ├── ai/
│   │   ├── gemini.py          # Google Gemini client
│   │   ├── openai.py          # OpenAI ChatGPT client
│   │   ├── anthropic.py       # Claude API client
│   │   └── openrouter.py      # OpenRouter unified proxy
│   ├── vault/
│   │   ├── crypto.py          # Machine-ID salt encryption
│   │   └── manager.py         # Key lifecycle management
│   ├── utils/
│   │   ├── logger.py          # Structured logging
│   │   └── updater.py         # Background GitHub version check
│   └── config.py              # Settings & defaults
├── templates/
│   ├── report.html            # PDF template (xhtml2pdf)
│   └── json_schema.json       # Export schema
├── tests/
│   ├── test_scanner.py
│   ├── test_vault.py
│   └── test_ai.py
├── requirements.txt           # Python dependencies
├── LICENSE                    # MIT License
└── README.md                  # This file
```

---

## 🚀 Installation & Setup

### Prerequisites

- **OS:** Kali Linux 2024+, Debian 11+, or WSL2 (Debian/Ubuntu)
- **Python:** 3.10 or later
- **Tools:** `nmap`, `netdiscover`, `curl` (auto-installed via installer)
- **Privileges:** Root access required for network operations

### Installation

```bash
# Clone repository
git clone https://github.com/yourusername/tree-framework.git
cd tree-framework

# Run 8-stage installer with ASCII tree visualization
sudo bash install.sh
```

**Installer stages:**
1. System dependency verification
2. Python 3.10+ validation
3. Required tools installation (nmap, netdiscover)
4. Python package installation (`pip install -r requirements.txt`)
5. Configuration directory setup (`~/.tree_sec/`)
6. Global PATH linking to `/usr/bin/tree-sec`
7. Machine ID registration for vault encryption
8. Initial AI provider configuration prompt

### Global CLI Access

After installation, execute framework from anywhere:

```bash
sudo tree-sec --help
```

The installer symlinks the entry point to `/usr/bin/tree-sec` for system-wide access.

---

## 🔄 How It Works & Assessment Workflow

TREE Framework follows a **5-stage automated pipeline:**

### Stage 1: Discovery
```bash
sudo tree-sec netscan --subnet 192.168.1.0/24
```
- ARP sweep to identify live hosts
- Nmap quick SYN scan (`-F`)
- Service enumeration on discovered ports
- Results stored in session cache

### Stage 2: Target Selection
```bash
sudo tree-sec select --target 192.168.1.50
```
- Interactive host selection from discovery results
- Sets active target for subsequent scans
- Stores fingerprint metadata (OS, services)

### Stage 3: Comprehensive Scanning
```bash
sudo tree-sec scan --aggressive
```
- Full TCP SYN scan (`-sS`)
- OS detection and version probing (`-O -A`)
- Exploit-DB cross-reference via `searchsploit`
- Anonymous credential testing (FTP, SSH)
- Results aggregated into vulnerability tree

### Stage 4: AI-Powered Triage
```bash
sudo tree-sec analyze --provider claude
```
- Real-time token streaming from selected AI provider
- Contextual risk assessment
- Remediation recommendations
- CVSS scoring aggregation

### Stage 5: Report & Export
```bash
sudo tree-sec report --format pdf
```
- Styled PDF compilation (xhtml2pdf)
- JSON export for automation
- Markdown summary generation

---

## 📖 Command Reference

| Command | Syntax | Description |
|---------|--------|-------------|
| **netscan** | `tree-sec netscan [--subnet CIDR]` | Discover live hosts via ARP & Nmap SYN sweep |
| **select** | `tree-sec select --target HOST` | Set active target for scanning |
| **set target** | `tree-sec set target HOST [--port PORT]` | Configure target with optional port override |
| **scan** | `tree-sec scan [--aggressive] [--timeout SEC]` | Execute full vulnerability scan on target |
| **analyze** | `tree-sec analyze [--provider PROVIDER]` | Run AI triage; stream results in real-time |
| **report** | `tree-sec report [--format pdf\|json\|md]` | Compile assessment report |
| **export** | `tree-sec export --format json --output FILE` | Export raw scan data |
| **show options** | `tree-sec show options` | Display current session config |
| **key list** | `tree-sec key list` | List configured AI provider keys |
| **key add** | `tree-sec key add --provider PROVIDER --key KEY` | Add encrypted AI credential |
| **key switch** | `tree-sec key switch --provider PROVIDER` | Switch active AI provider |
| **key remove** | `tree-sec key remove --provider PROVIDER` | Delete encrypted credential |

### Supported AI Providers

- `gemini` – Google Gemini Pro
- `openai` – OpenAI GPT-4 / GPT-3.5-turbo
- `anthropic` – Claude 3 Opus/Sonnet/Haiku
- `openrouter` – OpenRouter unified proxy

### Example Workflow

```bash
# 1. Scan subnet
sudo tree-sec netscan --subnet 10.0.0.0/24

# 2. Select target
sudo tree-sec select --target 10.0.0.5

# 3. Configure AI
tree-sec key add --provider claude --key sk-ant-xxx...
tree-sec key switch --provider claude

# 4. Run scan
sudo tree-sec scan --aggressive --timeout 300

# 5. Analyze with AI
sudo tree-sec analyze

# 6. Generate report
sudo tree-sec report --format pdf --output assessment_10.0.0.5.pdf
```

---

## 🔐 Encrypted Key Vault

The vault securely stores AI provider credentials using machine-identity bound encryption.

### Configuration File

Located at: `~/.tree_config.json`

```json
{
  "machine_id": "f8f9fa0b1c2d3e4f5a6b7c8d",
  "providers": {
    "anthropic": {
      "key": "encrypted:$2a$12$...",
      "active": true
    },
    "openai": {
      "key": "encrypted:$2a$12$...",
      "active": false
    }
  },
  "session": {
    "target": "192.168.1.50",
    "provider": "anthropic"
  }
}
```

### Key Management

```bash
# List all keys (shows provider & active status)
tree-sec key list

# Add new provider
tree-sec key add --provider openai --key sk-proj-xxx...

# Switch active provider
tree-sec key switch --provider gemini

# Remove provider key
tree-sec key remove --provider openai --confirm
```

### Security Details

- **Encryption:** AES-256-GCM
- **Salt:** Machine ID from `/etc/machine-id` (immutable per system)
- **Storage:** `~/.tree_config.json` with `0600` permissions
- **At-Rest:** All API keys encrypted; never logged or output in plaintext

---

## 📦 Dependencies

### System-Level
- `nmap` (≥7.80) – Network scanning
- `netdiscover` (≥0.3) – ARP enumeration
- `xhtml2pdf` – PDF rendering

### Python Packages
See `requirements.txt`:

```
requests>=2.28.0
pydantic>=2.0.0
cryptography>=41.0.0
typer>=0.9.0
google-generativeai>=0.3.0
openai>=1.3.0
anthropic>=0.15.0
xhtml2pdf>=0.2.15
pyyaml>=6.0
```

Install via:
```bash
pip install -r requirements.txt
```

---

## ⚙️ Configuration

### Environment Variables

```bash
# Override default config directory
export TREE_HOME=/custom/path

# Enable debug logging
export TREE_DEBUG=1

# Disable update checks
export TREE_NO_UPDATE_CHECK=1
```

### Default Settings (`tree_sec/config.py`)

```python
DEFAULT_SCAN_TIMEOUT = 300  # seconds
DEFAULT_NMAP_FLAGS = "-sS -O -F"
MAX_CONCURRENT_PROBES = 10
AI_STREAM_TIMEOUT = 60
UPDATE_CHECK_INTERVAL = 86400  # daily
```

---

## 📊 Version Changelog

### v2.4.0 (Current)
- **New:** Background update checks on startup (non-blocking, silent if current)
- **Fix:** WSL2 Cairo rendering in PDF reports (xhtml2pdf compatibility)
- **Improved:** AI provider fallback logic (auto-retry on token limits)
- **Security:** Encrypted vault now uses AES-256-GCM (upgraded from AES-128)

### v2.3.0
- **New:** OpenRouter support for unified provider abstraction
- **New:** Real-time token streaming across all 4 AI providers
- **Improved:** Nmap service version detection accuracy
- **Fix:** FTP anonymous login edge cases

### v2.2.0
- **New:** Encrypted credential vault with machine-ID binding
- **New:** Key lifecycle management (`key add/remove/switch/list`)
- **Improved:** Report PDF styling and CVSS formatting
- **Fix:** JSON export schema validation

### v2.1.0
- **New:** Web crawler for target discovery
- **New:** Anonymous SSH/FTP credential testing
- **Improved:** Multi-phase TCP enumeration (SYN → Version → Script)
- **Fix:** Nmap output parsing for edge-case fingerprints

### v2.0.0
- **Major Rewrite:** Multi-provider AI core (Google Gemini, OpenAI, Anthropic)
- **New:** 5-stage assessment pipeline with streaming triage
- **New:** Global CLI via `sudo tree-sec`
- **Breaking:** Removed legacy XML report format (now JSON/PDF only)

---

## 🧪 Testing

Run test suite:

```bash
pytest tests/ -v
```

Test coverage:
- `test_scanner.py` – Nmap orchestration, host discovery
- `test_vault.py` – Encryption, key rotation, machine-ID binding
- `test_ai.py` – Provider streaming, token validation, fallback logic

---

## 🤝 Contributing

Contributions welcome. Please:

1. Fork repository
2. Create feature branch (`git checkout -b feature/new-scanner`)
3. Write tests for new functionality
4. Submit pull request with description

---

## 🐛 Known Issues & Limitations

- **WSL1:** Not supported; requires WSL2 with systemd-resolved
- **Privilege Escalation:** Network scans require `sudo`; some tools require root for raw socket access
- **Parallel Scans:** Limited to 10 concurrent threads to avoid port exhaustion
- **AI Quotas:** Dependent on provider rate limits; implement backoff strategies for high-volume scans

---

## 📝 License

MIT License. See [LICENSE](LICENSE) file for details.

```
Copyright (c) 2024 TREE Framework Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 📞 Support & Resources

- **Issues:** [GitHub Issues](https://github.com/yourusername/tree-framework/issues)
- **Docs:** Full API documentation in `/docs/`
- **Community:** Security research discussions in `#tree-framework` on [community platform]

---

**Built for penetration testers by penetration testers.** Security through automation.
