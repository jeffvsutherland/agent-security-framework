# ASF-26: Website Security

## Overview

Securing the public-facing website/dashboard.

## Threat Model

- XSS, CSRF, SQL Injection
- Bot Abuse
- Prompt Injection
- Data Exfiltration

## Security Controls

- HTTPS/TLS 1.3
- WAF with security headers
- Rate Limiting
- OIDC/SAML Auth
- mTLS for agents

## Docker Hardening

- No-new-privileges
- Read-only rootfs
- Cap-drop ALL
- Network isolation

## References

- security-v3-comprehensive.md
- docker-templates/
