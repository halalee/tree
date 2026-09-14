import datetime
from xhtml2pdf import pisa
import markdown

CSS_STYLES = """
@page {
    size: a4 portrait;
    margin: 20mm 15mm 20mm 15mm;
}

body {
    font-family: Helvetica, Arial, sans-serif;
    color: #2b2b2b;
    font-size: 10pt;
    line-height: 1.45;
}

.header-banner {
    background-color: #0d1117;
    padding: 16px;
    border-radius: 4px;
    margin-bottom: 20px;
    border-left: 6px solid #2ea043;
}

.header-title {
    color: #ffffff;
    font-size: 18pt;
    font-weight: bold;
    margin: 0;
}

.header-subtitle {
    color: #8b949e;
    font-size: 9.5pt;
    margin-top: 4px;
}

.meta-box {
    background-color: #f6f8fa;
    border: 1px solid #d0d7de;
    border-radius: 4px;
    padding: 8px 12px;
    margin-bottom: 20px;
}

h1 {
    color: #0d1117;
    font-size: 14pt;
    font-weight: bold;
    border-bottom: 2px solid #2ea043;
    padding-bottom: 3px;
    margin-top: 18px;
    margin-bottom: 8px;
}

h2 {
    color: #0d1117;
    font-size: 12pt;
    font-weight: bold;
    border-bottom: 1px solid #d0d7de;
    padding-bottom: 2px;
    margin-top: 14px;
    margin-bottom: 6px;
}

h3 {
    color: #1f2328;
    font-size: 10.5pt;
    font-weight: bold;
    margin-top: 10px;
}

p, li {
    font-size: 9.5pt;
    color: #24292f;
}

ul, ol {
    margin-left: 15px;
    margin-bottom: 10px;
}

code {
    background-color: #eff1f3;
    font-family: Courier, monospace;
    font-size: 8.5pt;
    color: #cf222e;
}

pre {
    background-color: #161b22;
    color: #58a6ff;
    padding: 8px;
    font-family: Courier, monospace;
    font-size: 8pt;
    border-radius: 4px;
    margin-bottom: 12px;
}

table {
    width: 100%;
    border-collapse: collapse;
    margin: 12px 0;
}

th {
    background-color: #21262d;
    color: #ffffff;
    font-size: 8.5pt;
    padding: 5px;
    text-align: left;
    border: 1px solid #30363d;
}

td {
    font-size: 8.5pt;
    padding: 5px;
    border: 1px solid #d0d7de;
}

/* Color Badges */
.badge-critical {
    background-color: #d73a49;
    color: #ffffff;
    font-weight: bold;
}
.badge-high {
    background-color: #f66a0a;
    color: #ffffff;
    font-weight: bold;
}
.badge-medium {
    background-color: #e3b341;
    color: #1f2328;
    font-weight: bold;
}
.badge-low {
    background-color: #2da44e;
    color: #ffffff;
    font-weight: bold;
}
"""

def generate_pdf_report(markdown_text: str, target: str, output_path: str) -> bool:
    """Converts markdown audit report to a color-highlighted PDF."""
    html_content = markdown.markdown(markdown_text, extensions=['tables', 'fenced_code'])

    # Style severity badges
    html_content = html_content.replace("Critical", '<span class="badge-critical">&nbsp;CRITICAL&nbsp;</span>')
    html_content = html_content.replace("High", '<span class="badge-high">&nbsp;HIGH&nbsp;</span>')
    html_content = html_content.replace("Medium", '<span class="badge-medium">&nbsp;MEDIUM&nbsp;</span>')
    html_content = html_content.replace("Low", '<span class="badge-low">&nbsp;LOW&nbsp;</span>')

    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    full_html = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
{CSS_STYLES}
</style>
</head>
<body>

<div class="header-banner">
    <div class="header-title">TREE PENTEST AUDIT REPORT</div>
    <div class="header-subtitle">AI-Assisted Reconnaissance, Vulnerability Assessment & Threat Triage</div>
</div>

<div class="meta-box">
    <strong>Target System:</strong> {target}<br>
    <strong>Generated On:</strong> {now}<br>
    <strong>Auditing Engine:</strong> TREE Framework (Powered by Gemini)
</div>

{html_content}

</body>
</html>
"""

    with open(output_path, "wb") as pdf_file:
        pisa_status = pisa.CreatePDF(full_html, dest=pdf_file)

    return not pisa_status.err
