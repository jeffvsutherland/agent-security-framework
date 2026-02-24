# ASF-20: Enterprise Integration

## Reference Architecture

```mermaid
graph TB
    subgraph "Enterprise Cloud (AWS/GCP/Azure)"
        subgraph "VPC"
            subgraph "Public Subnet"
                ALB[Application Load Balancer<br/>WAF + DDoS Protection]
            end
            
            subgraph "Private Subnet - Web"
                Nginx[Nginx Reverse Proxy<br/>TLS Termination]
                WebApp[Web Application<br/>Dashboard/WordPress]
            end
            
            subgraph "Private Subnet - API"
                APIGW[API Gateway<br/>Rate Limiting + Auth]
                Agents[ASF Agent Pool]
            end
            
            subgraph "Private Subnet - Data"
                DB[(PostgreSQL<br/>RDS/Aurora)]
                Redis[(ElastiCache)]
                Vault[HashiCorp Vault<br/>Secrets Management]
            end
            
            subgraph "Security & Monitoring"
                WAF[Web Application Firewall]
                GuardDuty[Cloud Native SIEM<br/>GuardDuty/Defender]
                Prometheus[Prometheus + Grafana]
                ELK[ELK Stack<br/>Centralized Logging]
            end
        end
        
        SSO[Identity Provider<br/>Okta/Azure AD]
        SSO -->|SAML/OIDC| ALB
    end
    
    User -->|HTTPS| ALB
    ALB --> WAF
    WAF --> Nginx
    Nginx --> WebApp
    Nginx --> APIGW
    APIGW --> Agents
    Agents --> DB
    Agents --> Redis
    Agents -->|Fetch Secrets| Vault
    
    Agents -.->|Metrics| Prometheus
    Agents -.->|Logs| ELK
    ELK -.->|Alerts| GuardDuty
    GuardDuty -.->|Notify| SSO
```

## Sidecar Patterns

### Vault Sidecar for Secrets
```yaml
# Inject secrets from Vault into containers
vault:
  image: hashicorp/vault-sidecar:latest
  security_opt:
    - no-new-privileges:true
  cap_drop:
    - ALL
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock:ro
  environment:
    - VAULT_ADDR=https://vault.company.com
    - VAULT_ROLE=asf-agent
```

### Prometheus Metrics Sidecar
```yaml
metrics:
  image: asf/metrics-exporter:latest
  ports:
    - "9090:9090"
  environment:
    - METRICS_INTERVAL=60
```

### Fluentd Logging Forwarder
```yaml
logging:
  image: fluent/fluentd:v1.16
  volumes:
    - /var/log:/var/log
    - ./fluent.conf:/etc/fluent/fluent.conf
  environment:
    - FLUENTD_HOST=elasticsearch.company.com
    - FLUENTD_PORT=24224
```

## Deployment Patterns

## Overview

Enterprise integration package for large organizations.

## Core Components

- SSO/SAML/OIDC
- RBAC + Secrets Management
- Centralized Logging (ELK/Splunk)
- Metrics (Prometheus/Grafana)
- Compliance/Audit
- Kubernetes Ready

## Deliverables

| File | Description |
|------|-------------|
| ASF-ENTERPRISE-INTEGRATION-GUIDE.md | Primary guide |
| ASF-ENTERPRISE-API-ENDPOINTS.md | API definitions |
| ASF-ENTERPRISE-PRICING-LICENSING.md | Commercial model |

## Reference Architectures

- AWS EKS
- On-Premises (Docker/K8s)

## References

- ASF-17-REST-API.md
- docker-templates/
