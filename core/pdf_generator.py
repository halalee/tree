import re
import datetime
import markdown
from xhtml2pdf import pisa

CSS_STYLES = """
@page {
    size: a4 portrait;
    margin: 2cm;
}

body {
    font-family: Helvetica, Arial, sans-serif;
    font-size: 10pt;
    line-height: 1.5;
    color: #222222;
}

.header-banner {
    background-color: #1a1a1a;
    color: #00ff66;
    padding: 16px;
    text-align: center;
    border-radius: 4px;
    margin-bottom: 20px;
}

.header-title {
    font-size: 18pt;
    font-weight: bold;
    letter-spacing: 1px;
}

.header-subtitle {
    font-size: 9pt;
    color: #cccccc;
    margin-top: 4px;
}

.meta-box {
    background-color: #f4f4f4;
    border-left: 4px solid #00aa44;
    padding: 10px 14px;
    margin-bottom: 20px;
    font-size: 9pt;
}

h1 {
    font-size: 14pt;
    color: #111111;
    border-bottom: 1px solid #cccccc;
    padding-bottom: 4px;
    margin-top: 18px;
}

h2 {
    font-size: 12pt;
    color: #222222;
    margin-top: 14px;
}

h3 {
    font-size: 10.5pt;
    color: #333333;
}

p, li {
    font-size: 9.5pt;
}

code {
    font-family: Courier, monospace;
    background-color: #eeeeee;
    padding: 1px 3px;
    font-size: 8.5pt;
}

pre {
    background-color: #f8f8f8;
    border: 1px solid #e1e1e1;
    padding: 8px;
    font-family: Courier, monospace;
    font-size: 8pt;
}

table {
    width: 100%;
    border-collapse: collapse;
    margin: 12px 0;
}

th, td {
    border: 1px solid #dddddd;
    padding: 6px 8px;
    text-align: left;
    font-size: 8.5pt;
}

th {
    background-color: #f0f0f0;
    font-weight: bold;
}

.badge-critical {
    background-color: #d9534f;
    color: #ffffff;
    font-weight: bold;
    padding: 2px 5px;
    border-radius: 3px;
}

.badge-high {
    background-color: #f0ad4e;
    color: #ffffff;
    font-weight: bold;
    padding: 2px 5px;
    border-radius: 3px;
}

.badge-medium {
    background-color: #0275d8;
    color: #ffffff;
    font-weight: bold;
    padding: 2px 5px;
    border-radius: 3px;
}

.badge-low {
    background-color: #5cb85c;
    color: #ffffff;
    font-weight: bold;
    padding: 2px 5px;
    border-radius: 3px;
}
"""

def clean_unicode_for_pdf(text: str) -> str:
    """Replaces Unicode punctuation and symbols with PDF-safe equivalents."""
    replacements = {
        "\u2014": "--",       # Em dash
        "\u2013": "-",        # En dash
        "\u2018": "'",        # Left single quote
        "\u2019": "'",        # Right single quote
        "\u201c": '"',        # Left double quote
        "\u201d": '"',        # Right double quote
        "\u2022": "*",        # Bullet point
        "\u2026": "...",      # Ellipsis
        "\u2192": "->",       # Right arrow
        "\u2190": "<-",       # Left arrow
        "\u2713": "[OK]",     # Check mark
        "\u2714": "[OK]",     # Heavy check mark
        "\u2717": "[X]",      # Cross mark
        "\u2718": "[X]",      # Heavy cross mark
        "\u25cf": "*",        # Black circle
        "\u25cb": "o",        # White circle
        "\u25aa": "-",        # Black small square
        "\u25ab": "-",        # White small square
        "\u00a0": " ",        # Non-breaking space
    }
    for char, safe_char in replacements.items():
        text = text.replace(char, safe_char)
    
    # Strip remaining unprintable or multi-byte unicode emojis that Helvetica cannot render
    text = re.sub(r'[\U00010000-\U0010ffff]', '', text)
    return text

def generate_pdf_report(markdown_text: str, target: str, output_path: str) -> bool:
    """Converts the Markdown report into a clean, color-styled PDF without encoding artifacts."""
    safe_markdown = clean_unicode_for_pdf(markdown_text)

    html_content = markdown.markdown(safe_markdown, extensions=['tables', 'fenced_code'])

    # Inject risk badges
    html_content = html_content.replace("Critical", '<span class="badge-critical">&nbsp;CRITICAL&nbsp;</span>')
    html_content = html_content.replace("High", '<span class="badge-high">&nbsp;HIGH&nbsp;</span>')
    html_content = html_content.replace("Medium", '<span class="badge-medium">&nbsp;MEDIUM&nbsp;</span>')
    html_content = html_content.replace("Low", '<span class="badge-low">&nbsp;LOW&nbsp;</span>')

    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    full_html = f"""<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
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
        pisa_status = pisa.CreatePDF(full_html, dest=pdf_file, encoding='utf-8')

    return not pisa_status.err
