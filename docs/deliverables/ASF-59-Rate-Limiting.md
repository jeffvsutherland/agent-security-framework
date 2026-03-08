# ASF-59: Gateway Auth Rate Limiting

**Status:** REVIEW  
**Assignee:** Research Agent  
**Date:** March 7, 2026

---

## Description

Configure gateway authentication rate limiting to prevent brute force attacks.

## Configuration

```json
{
  "maxAttempts": 10,
  "windowMs": 60000,
  "lockoutMs": 300000
}
```

## Security Impact

- **Prevents brute force** - Max 10 attempts per minute
- **Account lockout** - 5 minute lockout after threshold
- **Rate limiting** - Protects auth endpoints

---

## DoD

- [x] Rate limiting configured
- [x] Tested
- [x] Ready for deploy

---

## See Also

- [ASF Overview](../README.md)
