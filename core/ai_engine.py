import json
import requests
import re

class AIEngine:
    SUPPORTED_PROVIDERS = ["gemini", "openai", "claude", "openrouter"]

    def __init__(self, provider: str = "gemini", api_key: str = "", model: str = None):
        self.provider = provider.lower() if provider else "gemini"
        self.api_key = api_key.strip()
        self.model = model

    def _compact_recon(self, recon_data: dict) -> dict:
        """Compact reconnaissance telemetry to essential security findings."""
        compact = {
            "target": recon_data.get("target"),
            "open_ports": recon_data.get("ports", []),
            "services": [],
            "cves_and_exploits": recon_data.get("exploitdb_matches", []),
            "service_audits": recon_data.get("service_audits", {}),
            "web_audits": recon_data.get("web_audits", [])
        }
        for svc in recon_data.get("nmap_services", []):
            if "error" not in svc:
                compact["services"].append({
                    "port": svc.get("port"),
                    "name": svc.get("name"),
                    "product": svc.get("product"),
                    "version": svc.get("version"),
                    "extra": svc.get("extrainfo")
                })
        return compact

    def stream_analyze_recon(self, recon_data: dict, verbose_callback=None):
        def log(msg: str):
            if verbose_callback:
                verbose_callback(msg)

        log(f"[bold blue][VERBOSE][/bold blue] Compacting reconnaissance telemetry for [cyan]{self.provider.upper()}[/cyan]...")
        compact_data = self._compact_recon(recon_data)
        serialized_telemetry = json.dumps(compact_data, indent=2)

        system_instruction = (
            "You are TREE-AI, an elite penetration tester and security auditor. "
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

        if self.provider == "gemini":
            yield from self._stream_gemini(system_instruction, prompt, log)
        elif self.provider == "openai":
            yield from self._stream_openai(system_instruction, prompt, log)
        elif self.provider == "claude":
            yield from self._stream_claude(system_instruction, prompt, log)
        elif self.provider == "openrouter":
            yield from self._stream_openrouter(system_instruction, prompt, log)
        else:
            raise ValueError(f"Unsupported AI provider: {self.provider}")

    # --- GEMINI STREAMING ---
    def _stream_gemini(self, system_instruction: str, prompt: str, log):
        models = [
            self.model or "gemini-flash-latest",
            "gemini-2.5-flash-lite",
            "gemini-3.5-flash",
            "gemini-2.5-flash"
        ]
        payload = {
            "system_instruction": {"parts": [{"text": system_instruction}]},
            "contents": [{"parts": [{"text": prompt}]}],
            "generationConfig": {"temperature": 0.2, "maxOutputTokens": 1800}
        }
        for mod in models:
            endpoint = f"https://generativelanguage.googleapis.com/v1beta/models/{mod}:streamGenerateContent?alt=sse&key={self.api_key}"
            log(f"[bold blue][VERBOSE][/bold blue] Attempting Gemini stream with [cyan]{mod}[/cyan]...")
            try:
                resp = requests.post(endpoint, json=payload, stream=True, timeout=(8, 35))
                if resp.status_code == 200:
                    for line in resp.iter_lines(decode_unicode=True):
                        if not line or not line.startswith("data: "):
                            continue
                        try:
                            item = json.loads(line[6:].strip())
                            candidates = item.get("candidates", [])
                            if candidates:
                                for part in candidates[0].get("content", {}).get("parts", []):
                                    text = part.get("text", "")
                                    if text:
                                        yield text
                        except Exception:
                            continue
                    return
                elif resp.status_code in (503, 429, 404):
                    log(f"[bold yellow][!] {mod} returned HTTP {resp.status_code}. Trying fallback...[/bold yellow]")
                    continue
                else:
                    raise RuntimeError(f"Gemini API Error {resp.status_code}: {resp.text}")
            except requests.exceptions.RequestException as e:
                log(f"[bold yellow][!] {mod} network error: {e}. Trying fallback...[/bold yellow]")
                continue
        raise RuntimeError("All Gemini candidate models failed to respond.")

    # --- OPENAI (CHATGPT) STREAMING ---
    def _stream_openai(self, system_instruction: str, prompt: str, log):
        endpoint = "https://api.openai.com/v1/chat/completions"
        target_model = self.model or "gpt-4o-mini"
        log(f"[bold blue][VERBOSE][/bold blue] Streaming with OpenAI model: [cyan]{target_model}[/cyan]...")
        payload = {
            "model": target_model,
            "messages": [
                {"role": "system", "content": system_instruction},
                {"role": "user", "content": prompt}
            ],
            "temperature": 0.2,
            "stream": True
        }
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        resp = requests.post(endpoint, headers=headers, json=payload, stream=True, timeout=(8, 35))
        if resp.status_code != 200:
            raise RuntimeError(f"OpenAI API Error {resp.status_code}: {resp.text}")

        for line in resp.iter_lines(decode_unicode=True):
            if not line or not line.startswith("data: "):
                continue
            chunk = line[6:].strip()
            if chunk == "[DONE]":
                break
            try:
                data = json.loads(chunk)
                delta = data.get("choices", [{}])[0].get("delta", {})
                content = delta.get("content", "")
                if content:
                    yield content
            except Exception:
                continue

    # --- ANTHROPIC (CLAUDE) STREAMING ---
    def _stream_claude(self, system_instruction: str, prompt: str, log):
        endpoint = "https://api.anthropic.com/v1/messages"
        target_model = self.model or "claude-3-5-haiku-20241022"
        log(f"[bold blue][VERBOSE][/bold blue] Streaming with Claude model: [cyan]{target_model}[/cyan]...")
        payload = {
            "model": target_model,
            "system": system_instruction,
            "messages": [{"role": "user", "content": prompt}],
            "max_tokens": 1800,
            "temperature": 0.2,
            "stream": True
        }
        headers = {
            "x-api-key": self.api_key,
            "anthropic-version": "2023-06-01",
            "content-type": "application/json"
        }
        resp = requests.post(endpoint, headers=headers, json=payload, stream=True, timeout=(8, 35))
        if resp.status_code != 200:
            raise RuntimeError(f"Claude API Error {resp.status_code}: {resp.text}")

        for line in resp.iter_lines(decode_unicode=True):
            if not line or not line.startswith("data: "):
                continue
            try:
                data = json.loads(line[6:].strip())
                if data.get("type") == "content_block_delta":
                    delta = data.get("delta", {})
                    if delta.get("type") == "text_delta":
                        yield delta.get("text", "")
            except Exception:
                continue

    # --- OPENROUTER STREAMING ---
    def _stream_openrouter(self, system_instruction: str, prompt: str, log):
        endpoint = "https://openrouter.ai/api/v1/chat/completions"
        target_model = self.model or "meta-llama/llama-3.3-70b-instruct:free"
        log(f"[bold blue][VERBOSE][/bold blue] Streaming via OpenRouter model: [cyan]{target_model}[/cyan]...")
        payload = {
            "model": target_model,
            "messages": [
                {"role": "system", "content": system_instruction},
                {"role": "user", "content": prompt}
            ],
            "stream": True
        }
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "HTTP-Referer": "https://github.com/halalee/tree",
            "X-Title": "TREE-Framework",
            "Content-Type": "application/json"
        }
        resp = requests.post(endpoint, headers=headers, json=payload, stream=True, timeout=(8, 35))
        if resp.status_code != 200:
            raise RuntimeError(f"OpenRouter API Error {resp.status_code}: {resp.text}")

        for line in resp.iter_lines(decode_unicode=True):
            if not line or not line.startswith("data: "):
                continue
            chunk = line[6:].strip()
            if chunk == "[DONE]":
                break
            try:
                data = json.loads(chunk)
                delta = data.get("choices", [{}])[0].get("delta", {})
                content = delta.get("content", "")
                if content:
                    yield content
            except Exception:
                continue

