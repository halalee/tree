import json
import time
import socket
import requests

socket.setdefaulttimeout(15)

class AIEngine:
    def __init__(self, api_key: str):
        self.api_key = api_key
        # Use the fast, working endpoint (fallback to gemini-flash-latest if needed)
        self.model = "gemini-flash-latest"

    def _compact_recon(self, recon_data: dict) -> dict:
        compact = {
            "target": recon_data.get("target"),
            "ports": recon_data.get("ports", []),
            "services": [],
            "exploitdb": [],
            "service_audits": recon_data.get("service_audits", {}),
            "web_audits": []
        }

        for s in recon_data.get("nmap_services", []):
            if "error" not in s:
                compact["services"].append({
                    "port": s.get("port"),
                    "service": s.get("name"),
                    "banner": f"{s.get('product', '')} {s.get('version', '')}".strip()
                })

        for m in recon_data.get("exploitdb_matches", []):
            compact["exploitdb"].append({
                "port": m.get("port"),
                "service": m.get("service"),
                "exploits": [e.get("title") for e in m.get("exploits", [])[:2]]
            })

        for w in recon_data.get("web_audits", []):
            audit = w.get("audit", {})
            compact["web_audits"].append({
                "port": w.get("port"),
                "technologies": audit.get("technologies", []),
                "paths": [p.get("path") for p in audit.get("discovered_paths", [])],
                "forms_detected": len(audit.get("forms_detected", [])),
                "has_upload": any(f.get("has_file_upload") for f in audit.get("forms_detected", []))
            })

        return compact

    def stream_analyze_recon(self, recon_data: dict, verbose_callback=None):
        def log(msg: str):
            if verbose_callback:
                verbose_callback(msg)

        log("[bold blue][VERBOSE][/bold blue] Compacting reconnaissance telemetry...")
        compact_data = self._compact_recon(recon_data)
        serialized_telemetry = json.dumps(compact_data, indent=2)
        log(f"[bold blue][VERBOSE][/bold blue] Telemetry prepared: {len(serialized_telemetry)} bytes, target: {compact_data.get('target')}")

        system_instruction = (
            "You are TREE-AI, a senior cybersecurity penetration tester and technical auditor. "
            "Analyze the target reconnaissance data concisely. Provide risk ratings, explain viable "
            "attack surfaces, and give prioritized defensive remediation steps."
        )

        prompt = f"""Audit the following network reconnaissance telemetry:

{serialized_telemetry}

Format using these exact Markdown sections:
1. Executive Summary & Overall Risk Rating (Critical / High / Medium / Low)
2. Open Services & Attack Surface Breakdown
3. Exploit-DB & Service Configuration Audit
4. Web Application Security Findings
5. Prioritized Remediation & Hardening Steps
"""

        payload = {
            "system_instruction": {
                "parts": [{"text": system_instruction}]
            },
            "contents": [
                {
                    "parts": [{"text": prompt}]
                }
            ],
            "generationConfig": {
                "temperature": 0.2,
                "maxOutputTokens": 1500
            }
        }

        endpoint = f"https://generativelanguage.googleapis.com/v1beta/models/{self.model}:streamGenerateContent?alt=sse&key={self.api_key}"
        headers = {"Content-Type": "application/json"}

        log(f"[bold blue][VERBOSE][/bold blue] Initiating SSE stream to [cyan]{self.model}[/cyan]...")
        
        response = requests.post(
            endpoint,
            headers=headers,
            data=json.dumps(payload),
            stream=True,
            timeout=(8, 30)
        )

        if response.status_code != 200:
            raise RuntimeError(f"API Error {response.status_code}: {response.text}")

        for line in response.iter_lines(decode_unicode=True):
            if not line or not line.startswith("data: "):
                continue
            
            data_str = line[6:].strip()
            try:
                data_json = json.loads(data_str)
                candidates = data_json.get("candidates", [])
                if candidates:
                    parts = candidates[0].get("content", {}).get("parts", [])
                    for part in parts:
                        text = part.get("text", "")
                        if text:
                            yield text
            except Exception:
                continue
