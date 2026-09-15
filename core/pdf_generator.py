import re

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
    
    # Strip any remaining unprintable or multi-byte unicode emojis that Helvetica cannot render
    text = re.sub(r'[\U00010000-\U0010ffff]', '', text)
    return text

def generate_pdf_report(markdown_text: str, target: str, output_path: str) -> bool:
    """Converts the Markdown report into a clean, color-styled PDF without encoding artifacts."""
    # 1. Clean unicode symbols that break default PDF fonts
    safe_markdown = clean_unicode_for_pdf(markdown_text)

    # 2. Convert to HTML
    html_content = markdown.markdown(safe_markdown, extensions=['tables', 'fenced_code'])

    # 3. Inject risk badges
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
