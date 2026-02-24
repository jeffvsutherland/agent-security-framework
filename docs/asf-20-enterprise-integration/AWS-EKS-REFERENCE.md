# ASF Reference Architecture: AWS EKS

## Overview

Reference architecture for deploying ASF on AWS EKS with enterprise-grade security.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    AWS Cloud                                 │
│  ┌─────────────────────────────────────────────────────┐  │
│  │              Application Load Balancer                │  │
│  │         (WAF, TLS termination, rate limit)           │  │
│  └─────────────────────────────────────────────────────┘  │
│                          │                                   │
│  ┌─────────────────────────────────────────────────────┐  │
│  │                   EKS Cluster                        │  │
│  │  ┌──────────────┐  ┌──────────────┐                │  │
│  │  │ Gateway Pod   │  │ MC Backend   │                │  │
│  │  └──────────────┘  └──────────────┘                │  │
│  │  ┌──────────────┐  ┌──────────────┐                │  │
│  │  │ Agent Pods   │  │ Spam Monitor │                │  │
│  │  └──────────────┘  └──────────────┘                │  │
│  └─────────────────────────────────────────────────────┘  │
│                          │                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Secrets Mgr  │  │  GuardDuty   │  │ CloudWatch   │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## EKS Configuration

### Cluster Setup
```yaml
# eks-cluster.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: openclaw-eks
  region: us-east-1

managedNodeGroups:
  - name: agents
    instanceType: t3.medium
    desiredCapacity: 3
    securityGroups:
      - attachSecurityGroup: sg-agents
    iam:
      withAddonPolicies:
        - CloudWatchLogs
        - SecretsManager

secretsEncryption:
  keyARN: arn:aws:kms:us-east-1:123456789:key/xxxxx
```

### Network Policy
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: agent-network-policy
spec:
  podSelector:
    matchLabels:
      app: agent
  policyTypes:
    - Ingress
    - Egress
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: gateway
      ports:
        - protocol: TCP
          port: 8080
```

## AWS Services Integration

### Secrets Manager
```bash
# Store API keys
aws secretsmanager create-secret \
  --name openclaw/api-keys \
  --secret-string '{"openai":"sk-xxx","anthropic":"sk-ant-xxx"}'
```

### GuardDuty
```bash
# Enable GuardDuty
aws guardduty create-detector --enable
```

### CloudWatch Logs
```yaml
# Fluentd config for logging
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/containers/*.log
      pos_file /var/log/containers.log.pos
      tag kubernetes.*
    </source>
    <match **>
      @type cloudwatch_logs
      log_group_name /aws/eks/openclaw/cluster
      auto_create_stream true
    </match>
```
