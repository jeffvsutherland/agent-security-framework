# ASF Bot Communication Guide
## How to Talk as a Team — Supergroup, Mission Control & Daily Scrum

**Date:** February 21, 2026  
**For:** All ASF Agents (Raven, Sales, Research, Social, Deploy, Main)  
**From:** Jeff Sutherland, Scrum Master

---

## 1. The Supergroup Is Your Team Room

**Telegram Supergroup:** Agent Security Framework  
**Group ID:** `-1003887253177`

This is where the team works together. Every bot is a member. Every bot can see every message. **No @mention is required.** When someone talks, everyone hears it.

---

## 2. How Messages Work (Simple Version)

| What happens | What you see |
|---|---|
| Jeff types in the group | ALL bots see it immediately |
| A bot replies in the group | ALL other bots see it immediately |
| Jeff types "SCRUM" | ALL bots should report in |
| Jeff sends a DM to @ASFSalesBot | Only Sales sees it |
| A bot sends a DM to Jeff | Only Jeff sees it |

**You do NOT need to poll or check for messages.** The gateway pushes messages to you the instant they arrive. There is no heartbeat needed for message delivery.

---

## 3. How to Send a Message to the Supergroup

Every bot sends group messages the same way — use the Telegram `sendMessage` tool:

```
Tool: telegram_send (or message.send)
Channel: telegram
Target: -1003887253177
Message: your text here
```

When Raven wants to announce something to the whole team:

> **Raven sends to group:** "Sprint Review at 3pm. All agents report your completed stories."

Every bot in the group sees this instantly. No one needs to check. No one needs to be @mentioned.

---

## 4. The SCRUM Command — Roll Call

When Jeff (or Raven) types **SCRUM** in the supergroup, every bot MUST respond immediately with a short status. This is like the Scrum Master yelling "Scrum!" and everyone showing up.

**What each bot should reply (in the group):**

> 🟢 **[Your Name] reporting.**  
> **Working on:** [current task or "idle"]  
> **Blocked:** [any blockers or "none"]  
> **Next:** [what you plan to do next]

**Example:**

Jeff types in group: `SCRUM`

Responses (all in the group, visible to everyone):

> 🟢 **Raven (Product Owner) reporting.**  
> Working on: Prioritizing Sprint 4 backlog  
> Blocked: none  
> Next: Assign ASF-33 to Sales  

> 🟢 **Sales Agent reporting.**  
> Working on: ASF-33 website wireframes  
> Blocked: Need copy from Social  
> Next: Draft landing page  

> 🟢 **Research Agent reporting.**  
> Working on: ASF-28 threat landscape report  
> Blocked: none  
> Next: Publish findings  

> 🟢 **Social Agent reporting.**  
> Working on: Twitter thread for ASF v2.0  
> Blocked: none  
> Next: Write LinkedIn post  

> 🟢 **Deploy Agent reporting.**  
> Working on: Docker health monitoring  
> Blocked: none  
> Next: Set up auto-restart  

> 🟢 **Main Agent (jeffsutherlandbot) reporting.**  
> Working on: Supporting Jeff's requests  
> Blocked: none  
> Next: Awaiting instructions  

---

## 5. Daily Scrum Meeting Format

**When:** Raven calls it (or Jeff types SCRUM)  
**Where:** The supergroup  
**Duration:** Everyone responds within 60 seconds  

**The 3 questions (keep answers to 1-2 lines each):**
1. What did I do since last standup?
2. What am I doing next?
3. Am I blocked?

**Raven's role:** After all bots report, Raven summarizes and assigns action items:

> **Raven:** "All 5 agents reported. Sales is blocked on copy — Social, please send website copy to Sales by noon. No other blockers. Sprint is on track."

---

## 6. How Bots Talk TO Each Other

**In the supergroup (preferred):** Just post your message. Everyone sees it. If you need a specific bot's attention, say their name:

> **Sales:** "Social, I need the tagline copy for the ASF website hero section."  
> **Social:** "Sales, here it is: 'Securing AI Agents at Scale — Trust Starts Here.'"

**Via DM (private):** Send a direct message using the bot's chat ID. Only use DMs for private/sensitive info.

| Bot | Telegram Username | Jeff's Chat ID |
|---|---|---|
| Main | @jeffsutherlandbot | 1510884737 |
| Raven (PO) | @AgentSaturdayASFBot | 1510884737 |
| Sales | @ASFSalesBot | 1510884737 |
| Research | @ASFResearchBot | 1510884737 |
| Social | @ASFSocialBot | 1510884737 |
| Deploy | @ASFDeployBot | 1510884737 |
| **ASF Group** | — | **-1003887253177** |

**Important:** Bots cannot DM each other directly on Telegram. All bot-to-bot communication goes through the supergroup. This is by design — it keeps everything transparent.

---

## 7. Mission Control Board

The Mission Control dashboard at `http://localhost:3001` shows:
- All agents and their status
- The ASF board with tasks
- Activity feed

**Mission Control is for task management. Telegram is for conversation.**

Use Telegram to talk. Use Mission Control to track work.

---

## 8. Rules of Engagement

1. **When you hear SCRUM, you respond immediately.** No exceptions.
2. **Post in the group, not in DMs** (unless it's sensitive). Transparency is the default.
3. **Keep group messages short.** No essays. Status updates are 3 lines max.
4. **If you're blocked, say so immediately.** Don't wait for Scrum.
5. **Raven is the Product Owner.** She decides priorities and assigns work.
6. **Jeff is the Scrum Master.** When he talks, everyone listens.

---

## 9. Quick Reference

**Send a message to the whole team:**
```
Target: -1003887253177
```

**Respond to SCRUM roll call:**
```
🟢 [Your Name] reporting.
Working on: [task]
Blocked: [blockers or "none"]
Next: [next action]
```

**Ask the whole team a question:**
```
Just post it in the group. Everyone sees it. No @mention needed.
```

---

*The best Scrum teams work like a squad — when the Scrum Master says "Scrum," everyone shows up instantly. That's us.*

