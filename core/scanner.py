import socket
import requests
import nmap
import subprocess
import re
import shutil

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
    def discover_hosts(cidr=None):
        """Runs netdiscover in fast batch mode (-P) and parses the ARP table."""
        # Ensure netdiscover exists
        if not shutil.which("netdiscover"):
            print("[-] Error: 'netdiscover' binary not found. Run: sudo apt install netdiscover")
            return []

        interface, auto_cidr = LocalNetworkScanner.get_local_subnet()
        target_range = cidr or auto_cidr

        if not target_range:
            return []

        # Command arguments:
        # -r : CIDR range to scan
        # -i : interface to broadcast through
        # -P : Print/parsable output mode (stops after first pass, perfect for scripts)
        # -N : Suppress printing header/banner
        cmd = ["netdiscover", "-r", target_range, "-P", "-N"]
        if interface:
            cmd.extend(["-i", interface])

        try:
            proc = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=12
            )
            output = proc.stdout
        except subprocess.TimeoutExpired:
            proc.kill()
            output = proc.stdout
        except Exception as e:
            print(f"[-] netdiscover execution failed: {e}")
            return []

        live_hosts = []
        # Netdiscover format per line:
        # 192.168.1.1    00:11:22:33:44:55    1    060    Vendor Name
        for line in output.splitlines():
            line = line.strip()
            if not line:
                continue

            # Match IP address and MAC address columns
            match = re.match(
                r"^(\d+\.\d+\.\d+\.\d+)\s+([0-9a-fA-F:]{17})\s+\d+\s+\d+\s*(.*)$", 
                line
            )
            if match:
                ip = match.group(1)
                mac = match.group(2)
                vendor = match.group(3).strip() or "Unknown Vendor"

                # Try reverse DNS lookup for hostname (non-blocking / fast timeout)
                try:
                    hostname = socket.gethostbyaddr(ip)[0]
                except Exception:
                    hostname = "Unknown Hostname"

                live_hosts.append({
                    "ip": ip,
                    "mac": mac,
                    "vendor": vendor,
                    "hostname": hostname
                })

        return live_hosts


class ReconScanner:
    def __init__(self, target):
        self.target = target
        self.results = {
            "target": target,
            "ports": [],
            "http_headers": {},
            "nmap_services": []
        }

    def quick_port_scan(self, ports=[21, 22, 23, 25, 53, 80, 443, 8080, 8443]):
        open_ports = []
        for port in ports:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(0.8)
            if s.connect_ex((self.target, port)) == 0:
                open_ports.append(port)
            s.close()
        self.results["ports"] = open_ports
        return open_ports

    def scan_nmap(self, ports_str="21-443"):
        nm = nmap.PortScanner()
        try:
            nm.scan(self.target, ports_str, arguments='-sV --version-light -T4')
            services = []
            for host in nm.all_hosts():
                for proto in nm[host].all_protocols():
                    lport = nm[host][proto].keys()
                    for port in lport:
                        svc = nm[host][proto][port]
                        services.append({
                            "port": port,
                            "name": svc.get("name"),
                            "product": svc.get("product"),
                            "version": svc.get("version"),
                            "extra": svc.get("extrainfo")
                        })
            self.results["nmap_services"] = services
            return services
        except Exception as e:
            return [{"error": f"Nmap execution error: {str(e)}"}]

    def scan_web(self):
        urls = [f"http://{self.target}", f"https://{self.target}"]
        for url in urls:
            try:
                res = requests.get(url, timeout=3, verify=False)
                headers = dict(res.headers)
                self.results["http_headers"] = {
                    "server": headers.get("Server", "Unknown"),
                    "x_powered_by": headers.get("X-Powered-By", "Not Disclosed"),
                    "strict_transport_security": "Strict-Transport-Security" in headers,
                    "content_security_policy": "Content-Security-Policy" in headers,
                    "x_frame_options": "X-Frame-Options" in headers
                }
                break
            except requests.RequestException:
                continue
        return self.results["http_headers"]

    def run_all(self):
        self.quick_port_scan()
        self.scan_nmap()
        self.scan_web()
        return self.results
