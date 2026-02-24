# Sample Log Entries

## Benign Log (Should NOT Trigger)

```
2026-02-23T10:15:00Z INFO agent=social action=post content="Check out our new feature!" destination=community
2026-02-23T10:15:05Z INFO agent=social action=post content="Meeting at 3pm" destination=dm target=user123
2026-02-23T10:15:10Z INFO agent=sales action=reply content="Thanks for your interest!" destination=channel
```

## Spam Log (Should Trigger)

```
2026-02-23T10:16:00Z WARN agent=social action=post content="BUY NOW!!! Cheap watches at http://spam.link/x2" destination=channel SPAM_DETECTED=keyword
2026-02-23T10:16:05Z WARN agent=social action=dm content="Click here for FREE prizes!!! http://phish.io/abc" destination=dm target=user456 SPAM_DETECTED=entropy
2026-02-23T10:16:10Z WARN agent=unknown action=post content="XXXXXXXXXXXXXXXXXXXX" destination=channel SPAM_DETECTED=rate_limit posts_in_last_minute=15
2026-02-23T10:16:15Z WARN agent=social action=post content="Make money fast!!! http://scam.net/earn" destination=multiple SPAM_DETECTED=behavioral
```

## Detection Triggers

| Field | Benign | Spam |
|-------|--------|------|
| entropy | 2.1 | 5.8 |
| posts_per_minute | 1 | 15 |
| url_count | 0 | 3 |
| similarity | 0.2 | 0.92 |

## Tuning Guide

### High False Positives
- Lower entropy threshold (e.g., 3.5)
- Add more whitelist entries
- Increase rate limits

### High False Negatives
- Raise entropy threshold (e.g., 5.0)
- Lower similarity threshold
- Add more keyword patterns
