# ASF-26: Website Security

## Overview
Security hardening for public-facing and internal websites/dashboards used by ASF agents.

## Threat Model

### Who/What Attacks?
- External attackers targeting web interfaces
- Malicious agents attempting XSS/CSRF
- Botnets for DDoS/brute force
- Phishing via agent-controlled content

### Attack Vectors
- SQL injection
- XSS (cross-site scripting)
- CSRF (cross-site request forgery)
- Credential stuffing
- API abuse
- DDoS

## Security Controls

### 1. HTTPS & TLS
```nginx
# nginx.conf - TLS hardening
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers HIGH:!aNULL:!MD5;
ssl_prefer_server_ciphers on;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
```

### 2. Web Application Firewall
```yaml
# docker-compose.yml with WAF
services:
  waf:
    image: modsecurity:apache
    volumes:
      - ./rules:/etc/modsecurity.d/rules
```

### 3. Rate Limiting
```nginx
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
limit_req zone=api burst=20 nodelay;
```

### 4. Bot Detection
- CAPTCHA on sensitive forms
- User-Agent filtering
- Behavioral analysis

### 5. Authentication
- OIDC/SAML federation
- API keys for agent-to-agent
- mTLS for internal services

### 6. Logging & Monitoring
- Access logs with request/response bodies
- Anomaly detection
- Alerting on suspicious patterns

## Docker Hardening

```yaml
services:
  website:
    read_only: true
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    environment:
      - SECURE_HEADERS=enabled
```

### Sample nginx.conf with Full Hardening
```nginx
# nginx.conf - Full security hardening
worker_processes auto;
error_log /var/log/nginx/error.log warn;

events {
    worker_connections 1024;
}

http {
    # Basic settings
    keepalive_timeout 65;
    types_hash_max_size 2048;

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # Rate Limiting Zones
    limit_req_zone $binary_remote_addr zone=general:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=api:10m rate=5r/s;
    limit_req_zone $binary_remote_addr zone=login:10m rate=1r/s;
    limit_conn_zone $binary_remote_addr zone=addr:10m;

    # Server Tokens
    server_tokens off;

    # Upstream (to internal services)
    upstream backend {
        server openclaw-gateway:8080;
    }

    server {
        listen 443 ssl http2;
        server_name example.com;

        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;

        # Connection Limits
        limit_conn addr 10;
        limit_req zone=general burst=20 nodelay;

        location /api/ {
            limit_req zone=api burst=10 nodelay;
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /login {
            limit_req zone=login burst=5 nodelay;
            # Add CAPTCHA challenge here
            proxy_pass http://backend;
        }

        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
        }
    }
}
```

### Content Security Policy for Dynamic Content
```nginx
# For Moltbook/dynamic agent content
add_header Content-Security-Policy "
    default-src 'self';
    script-src 'self' 'nonce-{random}' 'strict-dynamic';
    style-src 'self' 'unsafe-inline';
    img-src 'self' data: https:;
    font-src 'self';
    connect-src 'self' wss: https:;
    frame-ancestors 'none';
" always;
```

## Integration with ASF Tools

| Tool | Purpose |
|------|---------|
| `port-scan-detector.sh` | Detect port scans against web endpoints |
| `fake-agent-detector.sh` | Identify fake agent traffic |
| `infrastructure-security-check.sh` | Verify security configuration |

### Port Scan Detection (Cron)
```yaml
# Add to website service
command: >
  sh -c "cron && /root/port-scan-detector.sh & nginx -g 'daemon off;'"
```

## References
- security-v3-comprehensive.md
- moltbook-security-proposal-v2.md

---

**Story:** ASF-26  
**Status:** Ready for Review  
**Version:** 1.0.0
