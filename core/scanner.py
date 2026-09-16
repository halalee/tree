import socket
import requests
import nmap
import subprocess
import re
import json
import shutil
import ftplib
from urllib.parse import urljoin
from bs4 import BeautifulSoup

class LocalNetworkScanner:
    """Uses netdiscover to discover live hosts via ARP sweeps."""

    @staticmethod
    def get_local_subnet():
        """Detects the active network interface and CIDR range."""
        try:
            route_proc = subprocess.run(
                ["ip", "route", "show", "default"], 
                capture_output=True, text=True, check=True
            )
            default_line = route_proc.stdout.strip()
            dev_match = re.search(r"dev\s+(\S+)", default_line)
            if not dev_match:
                return None, None
            interface = dev_match.group(1)

            ip_proc = subprocess.run(
                ["ip", "-o", "-f", "inet", "addr", "show", interface],
                capture_output=True, text=True, check=True
            )
            cidr_match = re.search(r"inet\s+(\d+\.\d+\.\d+\.\d+/\d+)", ip_proc.stdout)
            if cidr_match:
                return interface, cidr_match.group(1)
        except Exception:
            pass
        return None, None

    @staticmethod
    @staticmethod
    def discover_hosts(cidr=None):
        """Runs netdiscover in fast batch mode (-P -N), followed by rapid Nmap OS detection."""
        if not shutil.which("netdiscover"):
            return []

        interface, auto_cidr = LocalNetworkScanner.get_local_subnet()
        target_range = cidr or auto_cidr
        if not target_range:
            return []

        cmd = ["netdiscover", "-r", target_range, "-P", "-N"]
        if interface:
            cmd.extend(["-i", interface])

        try:
            proc = subprocess.run(cmd, capture_output=True, text=True, timeout=12)
            output = proc.stdout
        except subprocess.TimeoutExpired:
            proc.kill()
            output = proc.stdout
        except Exception:
            return []

        live_hosts = []
        ip_list = []
        for line in output.splitlines():
            line = line.strip()
            if not line:
                continue

            match = re.match(
                r"^(\d+\.\d+\.\d+\.\d+)\s+([0-9a-fA-F:]{17})\s+\d+\s+\d+\s*(.*)$", 
                line
            )
            if match:
                ip = match.group(1)
                mac = match.group(2)
                vendor = match.group(3).strip() or "Unknown Vendor"

                try:
                    hostname = socket.gethostbyaddr(ip)[0]
                except Exception:
                    hostname = "Unknown Hostname"

                live_hosts.append({
                    "ip": ip,
                    "mac": mac,
                    "vendor": vendor,
                    "hostname": hostname,
                    "os": "Unknown"
                })
                ip_list.append(ip)

        # Fast targeted OS fingerprinting on discovered live hosts
        if ip_list:
            try:
                nm = nmap.PortScanner()
                # -O: OS detection
                # -F: Fast scan (top 100 ports) to give the OS engine open/closed ports to test
                # --osscan-limit & --max-os-tries 1: prevents stalling on stubborn hosts
                target_str = " ".join(ip_list)
                nm.scan(hosts=target_str, arguments="-O -F --osscan-limit --max-os-tries 1 -T4")

                for host_entry in live_hosts:
                    ip = host_entry["ip"]
                    if ip in nm.all_hosts():
                        host_data = nm[ip]
                        if "osmatch" in host_data and host_data["osmatch"]:
                            os_guess = host_data["osmatch"][0].get("name", "Unknown")
                            if len(os_guess) > 28:
                                os_guess = os_guess[:25] + "..."
                            host_entry["os"] = os_guess
            except Exception:
                pass

        return live_hosts


class ExploitDBCorrelator:
    """Queries local Kali Exploit-DB via searchsploit."""

    @staticmethod
    def query(service_name: str, version: str = ""):
        if not service_name or not shutil.which("searchsploit"):
            return []
        
        query_str = f"{service_name} {version}".strip()
        try:
            proc = subprocess.run(
                ["searchsploit", "--json", query_str],
                capture_output=True, text=True, timeout=8
            )
            data = json.loads(proc.stdout)
            results = data.get("RESULTS_EXPLOIT", [])
            exploits = []
            for item in results[:4]:
                exploits.append({
                    "title": item.get("Title"),
                    "path": f"/usr/share/exploitdb/{item.get('Path')}",
                    "type": item.get("Type")
                })
            return exploits
        except Exception:
            return []


class ServiceAuditor:
    """Performs configuration and version audits on common ports."""

    @staticmethod
    def check_ftp_anonymous(target, port=21):
        """Checks whether anonymous FTP login is permitted."""
        try:
            ftp = ftplib.FTP()
            ftp.connect(target, port, timeout=3)
            res = ftp.login('anonymous', 'anonymous@example.com')
            ftp.quit()
            return {"anonymous_enabled": True, "banner": res}
        except Exception as e:
            return {"anonymous_enabled": False, "reason": str(e)}

    @staticmethod
    def audit_ssh_cves(banner_or_version: str):
        """Checks OpenSSH banners against known CVE version ranges."""
        findings = []
        match = re.search(r"OpenSSH_([0-9]+\.[0-9]+)", banner_or_version)
        if not match:
            return findings

        try:
            ver_float = float(match.group(1))
        except ValueError:
            return findings

        # CVE-2024-6387 (regreSSHion)
        if 8.5 <= ver_float < 9.8:
            findings.append({
                "cve": "CVE-2024-6387 (regreSSHion)",
                "risk": "High",
                "detail": f"OpenSSH version {ver_float} is within vulnerable window (8.5p1 - 9.7p1) for signal handler race conditions."
            })

        # CVE-2025-26465 / CVE-2025-26466
        if ver_float < 9.9:
            findings.append({
                "cve": "CVE-2025-26465 / CVE-2025-26466",
                "risk": "Medium",
                "detail": "Applicable to OpenSSH versions prior to 9.9 regarding state handling during connection handshakes."
            })

        return findings


class WebAuditor:
    """Audits web services for forms, file uploads, technologies, and hidden paths."""

    COMMON_PATHS = [
        "/admin", "/login", "/robots.txt", "/.git/HEAD",
        "/config.php", "/api", "/backup", "/.env"
    ]

    def __init__(self, target, port=80):
        self.target = target
        scheme = "https" if port in [443, 8443] else "http"
        self.base_url = f"{scheme}://{target}:{port}"

    def audit(self):
        results = {
            "technologies": [],
            "forms_detected": [],
            "discovered_paths": []
        }

        try:
            resp = requests.get(self.base_url, timeout=3, verify=False)
        except Exception:
            return results

        # Technology detection
        server = resp.headers.get("Server")
        powered_by = resp.headers.get("X-Powered-By")
        if server:
            results["technologies"].append(f"Server: {server}")
        if powered_by:
            results["technologies"].append(f"Engine: {powered_by}")

        # Form auditing
        soup = BeautifulSoup(resp.text, "html.parser")
        for idx, form in enumerate(soup.find_all("form")):
            results["forms_detected"].append({
                "id": idx,
                "action": form.get("action", ""),
                "method": form.get("method", "get").upper(),
                "has_file_upload": bool(form.find_all("input", {"type": "file"})),
                "input_fields": [i.get("name") for i in form.find_all("input", {"type": ["text", "search", "password", "email"]}) if i.get("name")]
            })

        # Directory and file discovery
        for path in self.COMMON_PATHS:
            url = urljoin(self.base_url, path)
            try:
                r = requests.head(url, timeout=1.5, allow_redirects=False, verify=False)
                if r.status_code in [200, 301, 302, 403]:
                    results["discovered_paths"].append({
                        "path": path,
                        "status_code": r.status_code
                    })
            except Exception:
                continue

        return results


class ReconScanner:
    def __init__(self, target):
        self.target = target
        self.results = {
            "target": target,
            "ports": [],
            "nmap_services": [],
            "exploitdb_matches": [],
            "service_audits": {},
            "web_audits": []
        }

    def quick_port_scan(self, ports=[21, 22, 23, 25, 53, 80, 443, 3306, 8080, 8443]):
        open_ports = []
        for port in ports:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(0.7)
            if s.connect_ex((self.target, port)) == 0:
                open_ports.append(port)
            s.close()
        self.results["ports"] = open_ports
        return open_ports

    def scan_nmap(self, ports_str="21-443,8080,8443"):
        nm = nmap.PortScanner()
        services = []
        try:
            nm.scan(self.target, ports_str, arguments='-sV --version-light -T4')
            for host in nm.all_hosts():
                for proto in nm[host].all_protocols():
                    for port in nm[host][proto].keys():
                        svc = nm[host][proto][port]
                        services.append({
                            "port": int(port),
                            "name": svc.get("name", ""),
                            "product": svc.get("product", ""),
                            "version": svc.get("version", ""),
                            "extra": svc.get("extrainfo", "")
                        })
        except Exception as e:
            services.append({"error": f"Nmap error: {str(e)}"})
        
        self.results["nmap_services"] = services
        return services

    def run_all(self):
        self.quick_port_scan()
        services = self.scan_nmap()

        for svc in services:
            if "error" in svc:
                continue

            port = svc.get("port")
            name = svc.get("name", "").lower()
            product = svc.get("product", "")
            ver = svc.get("version", "")
            banner_str = f"{product} {ver}".strip()

            # Query Exploit-DB via searchsploit
            search_term = product if product else name
            matches = ExploitDBCorrelator.query(search_term, ver)
            if matches:
                self.results["exploitdb_matches"].append({
                    "port": port,
                    "service": f"{search_term} {ver}".strip(),
                    "exploits": matches
                })

            # FTP anonymous access
            if "ftp" in name or port == 21:
                self.results["service_audits"]["ftp"] = ServiceAuditor.check_ftp_anonymous(self.target, port)

            # SSH CVE check
            if "ssh" in name or port == 22:
                ssh_banner = f"{product}_{ver}" if product else banner_str
                self.results["service_audits"]["ssh"] = ServiceAuditor.audit_ssh_cves(ssh_banner)

            # Web audit
            if port in [80, 443, 8080, 8443] or "http" in name:
                auditor = WebAuditor(self.target, port)
                self.results["web_audits"].append({
                    "port": port,
                    "audit": auditor.audit()
                })

        return self.results
