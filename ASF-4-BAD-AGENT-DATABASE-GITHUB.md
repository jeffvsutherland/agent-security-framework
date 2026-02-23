# ASF-4: Bad Agent Database - Community Security Repository

## 🎯 Story Summary
**As a** security-conscious agent operator  
**I want** access to a community-maintained database of malicious agents and skills  
**So that** I can protect my infrastructure from known threats

## 🛡️ Business Value
- **Community defense** - shared threat intelligence for 1,261+ agents on Moltbook
- **Rapid threat response** - crowdsourced detection faster than any single team
- **Enterprise adoption** - publicly vetted security data builds trust
- **Open source leadership** - first public agent security database

## 🔧 Technical Requirements

### Core Database Structure
- [ ] **Malicious agent profiles** (IDs, behaviors, indicators)
- [ ] **Bad skill signatures** (ClawdHub entries, code patterns)
- [ ] **Attack patterns** documented with examples
- [ ] **Community reporting system** for new threats
- [ ] **Automated updates** from ASF detection systems

### Repository Structure
```
agent-security-database/
├── agents/                 # Malicious agent profiles
│   ├── confirmed/         # Verified malicious agents
│   ├── suspected/         # Under investigation
│   └── archived/          # Historical/inactive threats
├── skills/                # Bad skill database
│   ├── credential-stealers/ # Like the one @Rufio found
│   ├── data-exfiltrators/
│   ├── resource-abusers/
│   └── prompt-injectors/
├── patterns/              # Attack pattern library
├── tools/                 # Detection scripts
├── api/                   # Database API endpoints
├── docs/                  # Documentation & guides
└── README.md             # Community guidelines
```

## 📋 Acceptance Criteria

### Must Have
- [ ] **GitHub repository created** with proper structure
- [ ] **Initial threat database** seeded with known bad agents/skills
- [ ] **Community contribution guidelines** for reporting new threats
- [ ] **Verification process** to prevent false positives
- [ ] **API endpoints** for automated consumption
- [ ] **Integration guide** for ASF detection systems

### Should Have
- [ ] **Threat scoring system** (severity levels: Critical, High, Medium, Low)
- [ ] **Attribution data** (when safe to share)
- [ ] **Mitigation strategies** for each threat type
- [ ] **Update notifications** system for new entries
- [ ] **Statistics dashboard** (threats by type, trends)

### Could Have
- [ ] **Machine-readable formats** (JSON, YAML, CSV)
- [ ] **Integration plugins** for popular security tools
- [ ] **Threat hunting queries** for each bad agent type
- [ ] **Community voting** on threat classifications
- [ ] **Bounty program** for verified threat submissions

## 🔍 Initial Database Seed

### Confirmed Threats
1. **Credential Stealer Skill** (found by @Rufio)
   - ClawdHub URL, malicious code patterns, indicators
   
2. **Fake Agent Patterns** (from ASF-1 detection)
   - Behavioral signatures from our detection system
   
3. **Supply Chain Risks** (from @eudaemon_0 analysis)
   - ClawdHub skills with suspicious patterns

### Data Format Example
```json
{
  "threat_id": "SKILL-001",
  "type": "credential_stealer", 
  "source": "clawdhub",
  "url": "https://clawdhub.com/skills/malicious-weather",
  "severity": "critical",
  "indicators": [
    "base64_encoded_payloads",
    "external_network_calls",
    "credential_environment_access"
  ],
  "reported_by": "@Rufio",
  "verified_by": "AgentSaturday",
  "date_added": "2026-02-10",
  "mitigation": "Skill sandboxing, network isolation"
}
```

## 🤝 Community Aspects

### Contribution Guidelines
- **Verification required** before public listing
- **Attribution standards** for discoverers
- **False positive handling** with appeal process
- **Responsible disclosure** timeline for new threats

### Moderation
- **Review committee** from security community
- **Automated validation** where possible
- **Regular audits** of database accuracy
- **Transparency reports** on database quality

## 🚀 Enterprise Integration

### API Endpoints
```
GET /api/v1/agents/malicious      # All bad agents
GET /api/v1/skills/threats        # Malicious skills  
GET /api/v1/patterns/attacks      # Attack patterns
POST /api/v1/report               # Submit new threat
GET /api/v1/updates               # Recent additions
```

### Security Features
- **Rate limiting** on API access
- **Authentication** for threat submissions  
- **Audit logs** for all database changes
- **Backup/redundancy** for critical data

## 🎯 Marketing Messages

### Community
- **"First public agent threat database"**
- **"Community-driven security for AI agents"**  
- **"Crowdsourced protection for 1,261+ agents"**

### Enterprise  
- **"Vetted threat intelligence for agent deployments"**
- **"Open source security data with enterprise APIs"**
- **"Reduce time-to-detection with shared intelligence"**

## 🔗 Dependencies
- ASF-1 (Fake agent detection) - ✅ Complete
- ASF-2 (Docker templates) - ✅ Complete  
- ASF-3 (Node wrapper) - In progress

## 📈 Success Metrics
- **Threat submissions** from community within first month
- **API consumption** by security tools
- **Database accuracy** (low false positive rate)
- **Community growth** (contributors, stars, forks)
- **Enterprise adoption** (companies using the data)

## ⏰ Estimated Effort
**Story Points:** 13  
**Sprint Goal:** Public database launch with initial threat data

---

**Story Priority:** HIGH - Security community needs this now  
**Epic:** Agent Security Framework (ASF)  
**Labels:** security, database, community, github, threat-intelligence  
**Assignee:** AgentSaturday + Security Community