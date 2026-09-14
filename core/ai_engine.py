import json
from google import genai
from google.genai import types

class AIEngine:
    def __init__(self, api_key: str):
        # Initialize client with user's stored key
        self.client = genai.Client(api_key=api_key)
        # Use the updated model specified by the API response
        self.model = "gemini-3.6-flash"

    def analyze_recon(self, recon_data: dict) -> str:
        """Sends recon output to Gemini for defensive auditing and risk scoring."""
        system_instruction = (
            "You are TREE-AI, a senior cybersecurity penetration tester and defensive auditor. "
            "Your task is to analyze network reconnaissance data, identify exposed "
            "attack surfaces, assess risks (Low, Medium, High, Critical), explain potential "
            "vulnerabilities, and provide prioritized defensive mitigations."
        )

        prompt = f"""
Analyze the following reconnaissance telemetry and generate a structured audit report:

Reconnaissance Data:
{json.dumps(recon_data, indent=2)}

Format your response strictly using these Markdown sections:
1. Executive Assessment & Threat Level (Critical / High / Medium / Low)
2. Exposed Attack Surface & Service Analysis
3. Identified Vulnerabilities & Theoretical Attack Vectors
4. Prioritized Defensive Remediation & Hardening Steps
"""
        response = self.client.models.generate_content(
            model=self.model,
            contents=prompt,
            config=types.GenerateContentConfig(
                system_instruction=system_instruction,
                temperature=0.3
            )
        )
        return response.text
