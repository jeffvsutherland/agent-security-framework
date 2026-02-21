OMC login: HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM

http://localhost:3001/

Gateway Name: ASF Gateway
Gateway URL: ws://openclaw-gateway:18789
Gateway Token: uuI7HDktGsmbKPLeyJOCOib607dJoKWQybTXuGYMRm0
Workspace Root: /workspace 



Telegram:
  Old ID (-4991492317): 0 occurrences (should be 0)
  New ID (-1003887253177): 14 occurrences
jeffsutherland@JeffsMaudio4046 clawd % 

Problem: Your Telegram group was upgraded to a supergroup, which changed the chat ID. The old ID -4991492317 no longer existed.
What I did:
Identified the correct supergroup ID: The real ASF supergroup is -1003887253177 (title: "Agent Security Framework", type: supergroup)
Updated the OpenClaw config: Replaced all 14 occurrences of the dead group ID -4991492317 with -1003887253177 across:
Top-level groups and allowFrom
Every bot account's groups and allowFrom (default, research, social, deploy, sales, product-owner)
Verified all bots are members of the supergroup ✅
Confirmed privacy mode is OFF for all 6 bots — they can see all group messages ✅
Restarted the gateway — all Telegram providers started

FOSL Marissa Vulagmore admin