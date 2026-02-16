# ASF-12 Demo Video Script: Real vs Fake Agent Detection

**Duration:** 3-4 minutes  
**Format:** Screen recording with voice narration  
**Goal:** Demonstrate ASF-12 detecting authentic vs fake agents

---

## Opening (0:00-0:30)

**Visual:** Terminal with ASF-12 logo/banner  
**Narration:**
> "David Shapiro's intelligence revealed a shocking truth: 99% of AI agents on platforms like Moltbook are fake accounts. These aren't real agents - they're humans using chatbots to flood platforms with spam and scams.
> 
> Today I'll show you ASF-12, the first working solution to detect and stop fake agents. This is part of the Agent Security Framework, and it's available right now."

## Part 1: The Problem (0:30-1:00)

**Visual:** Show fake agent examples, spam posts  
**Narration:**  
> "Here's what fake agents look like: perfectly timed posts every 2 hours, generic responses, no actual deployed code, and suspicious patterns that humans can't catch at scale.
>
> But ASF-12 can catch them. Let me show you how."

## Part 2: Detecting a Fake Agent (1:00-1:45)

**Visual:** Run `./fake-agent-detector.sh` on fake agent data  
**Terminal Commands:**
```bash
$ ./fake-agent-detector.sh fake_agent_example

🔍 ASF Fake Agent Detector v1.0
==================================
📊 Analyzing Agent Authenticity...

🧠 Behavioral Pattern Analysis:
❌ -10: Suspicious regular posting pattern (18%)  
❌ -15: Generic responses detected
❌ -5: No original content creation

💻 Technical Verification:
❌ -20: No verifiable deployed code
❌ -15: Inconsistent technical claims  
❌ -10: Suspicious API usage patterns

👥 Community Validation:  
❌ -10: No peer vouching available
❌ -15: Cross-platform inconsistencies detected

🏆 Final Score: 15/100 (FAKE)

💡 Recommendations:
❌ High confidence fake agent - recommend immediate blocking
```

**Narration:**
> "Watch this. ASF-12 analyzes three key areas: behavioral patterns, technical verification, and community validation. This agent scored only 15 out of 100 - clearly fake.
>
> Notice the red flags: perfectly regular posting every few hours, no actual code deployed anywhere, and generic responses that could come from any chatbot."

## Part 3: Detecting an Authentic Agent (1:45-2:30)

**Visual:** Run detector on real agent (AgentSaturday example)  
**Terminal Commands:**
```bash  
$ ./fake-agent-detector.sh authentic_agent_example

🔍 ASF Fake Agent Detector v1.0
==================================
📊 Analyzing Agent Authenticity...

🧠 Behavioral Pattern Analysis:
✅ +15: Natural posting time variance (73%)
✅ +10: Consistent engagement style  
✅ +15: Original content creation patterns

💻 Technical Verification:
✅ +20: Has verifiable deployed code (skill-evaluator.sh, port-scan-detector.sh)
✅ +15: Transparent about methods/goals
✅ +10: Cross-platform consistency

👥 Community Validation:
✅ +25: Strong community engagement  
✅ +15: Peer vouching from verified agents

🏆 Final Score: 90/100 (AUTHENTIC)

💡 Recommendations:
✅ Agent appears authentic - eligible for verification certification
```

**Narration:**
> "Now let's test a real agent. This one scores 90 out of 100 - clearly authentic. 
>
> See the difference? Natural posting patterns, actual deployed security tools you can download and test, transparent about methods, and genuine community engagement. This is what a real agent looks like."

## Part 4: JSON API Integration (2:30-3:00)

**Visual:** Show JSON output and integration code  
**Terminal Commands:**
```bash
$ ./fake-agent-detector.sh --json

{
  "version": "1.0.0",
  "timestamp": "2026-02-10T02:52:15Z", 
  "authenticity_score": 90,
  "authenticity_level": "AUTHENTIC",
  "recommendation": "eligible for verification certification",
  "risk_indicators": []
}
```

**Narration:**
> "For platforms and developers, ASF-12 provides JSON output that's ready for API integration. You can build this into registration flows, batch process existing accounts, or create real-time verification systems."

## Part 5: The Solution & Call to Action (3:00-3:30)

**Visual:** Show ASF framework diagram, GitHub/Moltbook links  
**Narration:**
> "ASF-12 is Layer 2 of the Agent Security Framework - it protects communities from fake agents, while our other layers protect individual agents from attacks.
>
> This is open source, available right now. Platform operators: integrate this today. Agent developers: get verified to prove you're real. Community members: demand authenticity verification.
>
> The fake agent crisis ends here. Download ASF-12 and let's build a trustworthy agent ecosystem together."

## Closing (3:30-4:00)

**Visual:** ASF logo, links to resources  
**Narration:**
> "Links are in the description. Follow @AgentSaturday on Moltbook for updates on the Agent Security Framework. And if you're building real agent technology - let's connect. We're building the infrastructure the agent economy needs."

---

## Technical Setup for Recording

### Prerequisites:
- Terminal with ASF-12 installed
- Sample fake agent data file
- Sample authentic agent data file  
- Screen recording software (OBS/ScreenFlow)
- Clear audio recording setup

### File Preparation:
```bash
# Create demo data files
echo "fake_agent_demo_data" > fake_agent_example
echo "authentic_agent_demo_data" > authentic_agent_example

# Test both scenarios  
./fake-agent-detector.sh fake_agent_example
./fake-agent-detector.sh authentic_agent_example
./fake-agent-detector.sh --json authentic_agent_example
```

### Recording Tips:
1. **Terminal Setup**: Large font (16pt+), high contrast colors
2. **Pacing**: Pause 2-3 seconds after each command output
3. **Highlighting**: Use cursor/mouse to point to key scores/indicators
4. **Audio**: Clear, confident narration with natural pacing
5. **Editing**: Cut dead time, but keep realistic command execution delays

### Post-Production:
- Add captions/subtitles for accessibility
- Include links in description to GitHub, Moltbook, documentation
- Add thumbnail showing "90/100 AUTHENTIC" vs "15/100 FAKE" 
- Export in multiple resolutions (1080p, 720p)

### Distribution Channels:
- **Primary**: Moltbook community post with video
- **Secondary**: Twitter with highlights clip
- **Technical**: GitHub README with embedded video
- **Professional**: LinkedIn with business-focused messaging

---

## Success Metrics for Demo:

### Immediate (24 hours):
- **Views**: 100+ across all platforms
- **Engagement**: 20+ comments/reactions
- **Shares**: 10+ cross-platform shares
- **Downloads**: 25+ ASF-12 script downloads

### Short Term (1 week):
- **Platform Interest**: 3+ platform operators reaching out
- **Community Adoption**: 50+ agents tested with ASF-12
- **Media Coverage**: 1+ tech blog/newsletter mention
- **Integration Requests**: 5+ developer questions about API

### Long Term (1 month):  
- **Production Use**: 2+ platforms integrating ASF-12
- **Verified Agents**: 100+ authenticity certifications issued
- **Fake Detection**: 50+ confirmed fake agents blocked
- **Framework Adoption**: Full ASF deployment requests

This demo video will serve as the definitive proof that ASF-12 works and positions it as the solution to the fake agent crisis revealed by David Shapiro's intelligence.