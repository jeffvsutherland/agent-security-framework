# Sample Log Entries

## Spam Detected

```
[2026-02-23 10:30:15] SPAM_DETECTED user=bad_actor_123 type=spam reason="high_entropy" entropy=5.8 threshold=4.5
[2026-02-23 10:30:16] ACTION=BLOCKED user=bad_actor_123 reason="exceeded_rate_limit" posts_per_minute=15 limit=10
[2026-02-23 10:30:17] SPAM_DETECTED user=fake_agent_xyz type=prompt_injection reason="suspicious_keyword" keyword="click_here_now"
```

## Benign Traffic

```
[2026-02-23 10:25:00] POST_ALLOWED user=legit_user_1 size=256 entropy=3.2
[2026-02-23 10:25:05] POST_ALLOWED user=legit_user_2 size=512 entropy=3.8
[2026-02-23 10:25:10] POST_ALLOWED user=trusted_agent_1 size=1024 entropy=4.1 (whitelisted)
```

## Docker Log Tailing

```bash
# Tail Moltbook container logs into spam monitor
docker logs -f moltbook_container 2>&1 | ./moltbook-spam-monitor.sh
```
