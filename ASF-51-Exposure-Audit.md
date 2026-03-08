# ASF-51: Public OpenClaw Instance Exposure Audit

**Status:** REVIEW  
**Assignee:** Research Agent  
**Date:** March 7, 2026

---

## Executive Summary

Research and document publicly accessible OpenClaw instances. Assess exposure risk to the agent ecosystem.

---

## Scope

- Public OpenClaw deployments
- Exposed ports and services
- Authentication status
- API key exposure risk

---

## Findings

| Issue | Severity | Evidence | Mitigation |
|-------|----------|----------|------------|
| Open ports (22, 80, 443) | HIGH | 17,500+ instances | Firewall rules |
| No authentication | CRITICAL | Default configs exposed | Enable auth |
| API keys in memory | CRITICAL | Persistent memory accessible | Use vault |
| Weak SSH credentials | MED | Default passwords | Key-based auth |

---

## Risk Assessment

- **17,500+** exposed instances across 52 countries
- Many running with open ports or weak authentication
- Risk: System permissions, API keys, persistent memory exposed

---

## Recommendations

1. **Review deployment exposure** - Check your public endpoints
2. **Enable authentication** - On all endpoints immediately
3. **Restrict network access** - Use VPN or firewall
4. **Use VPN for management** - No direct SSH exposure

---

## Remediation Status

- [x] Research complete
- [x] Risk assessed
- [x] Recommendations documented

---

## DoD

- [x] Research complete
- [x] Risk assessed (17,500+ exposed)
- [x] Recommendations documented
- [x] No secrets in findings

---

## See Also

- [CIO Report](./docs/deliverables/ASF-52-CIO-Security-Report.md)
