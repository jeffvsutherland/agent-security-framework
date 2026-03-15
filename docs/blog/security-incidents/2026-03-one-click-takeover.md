# One-Click Agent Takeovers: Why ASF Sandboxing Beats Basic Docker

**Published:** March 15, 2026  
**Series:** AI Agent Breaches of 2026

## Data Affected
Full gateway control, host machine access, localStorage tokens, credentials, and complete agent takeover.

## Type of Breach
Remote Code Execution (RCE) – CVSS 8.8 (CVE-2026-25253 “ClawJacked”)

## Description
Discovered in early February 2026, this exploit allowed a malicious website to hijack WebSocket connections or extract tokens from localStorage, giving attackers complete control over the OpenClaw gateway and RCE on the underlying host. The attack worked even against instances bound only to localhost. It was part of a cluster of related vulnerabilities including authentication bypass and SSRF.

## How ASF Prevents This Breach
ASF requires token-based authentication with strict origin validation, mandatory sandboxing that goes well beyond basic Docker, and an automated pre-deployment exposure scanner. Runtime monitoring detects anomalous WebSocket behavior and blocks token leakage. The combination of these controls stops one-click takeovers that bypass simpler containerization.

[Insert screenshot: CVE-2026-25253 details]  
[Insert screenshot: WebSocket hijack attack flow diagram]

**References:**  
- CVE-2026-25253  
- Related CVEs (2026-28472, 2026-26322)

**Key Takeaway:** Sandboxing + origin control must be mandatory, not optional. ASF enforces this at the framework level.

---

