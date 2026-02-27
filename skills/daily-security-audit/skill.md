# SKILL: Daily Security Audit

**Description:** Scans the codebase for newly introduced vulnerabilities and updates the Mission Control board.
**Trigger:** Cron — 12:05 AM nightly (`5 0 * * *`)
**Agent:** Auditor
**Workspace:** agent-security-framework
**Prerequisite:** Runs 6 minutes after `sprint-rollover` to ensure board is clean.

## ⚠️ IMPORTANT: Read-Only Policy

This skill operates in **Read and Report** mode only. The Auditor agent must NOT attempt to fix code. All findings are injected as task cards into the backlog for the Architect to assign during daytime operations.

## Execution Steps

### 1. Run Static Analysis
Execute a security scan against the workspace source directories:

```bash
# Primary: semgrep (if available)
semgrep scan --config auto src/ > workspace/reports/semgrep_out.txt 2>&1

# Fallback: bandit for Python files
bandit -r src/ -f json > workspace/reports/bandit_out.json 2>&1

# Fallback: grep-based checks for common vulnerabilities
grep -rn "eval(" --include="*.py" --include="*.js" src/ > workspace/reports/grep_audit.txt 2>&1
grep -rn "subprocess.call.*shell=True" --include="*.py" src/ >> workspace/reports/grep_audit.txt 2>&1
grep -rn "os.system(" --include="*.py" src/ >> workspace/reports/grep_audit.txt 2>&1
grep -rn "exec(" --include="*.js" src/ >> workspace/reports/grep_audit.txt 2>&1
```

Use whichever tool is available. If none are installed, use the grep-based fallback.

### 2. Analyze the Output
- Read the scan output file(s).
- Identify any findings marked as `HIGH` or `CRITICAL`.
- Count total findings by severity level.

### 3. Log the Baseline
Append a summary to `workspace/reports/DAILY_SECURITY_LOG.md`:

```markdown
## YYYY-MM-DD — Security Scan Results

- **Scanner:** semgrep / bandit / grep-fallback
- **Time:** HH:MM:SS ET
- **Files Scanned:** N
- **Total Issues:** N
  - CRITICAL: N
  - HIGH: N
  - MEDIUM: N
  - LOW: N
- **Status:** CLEAN / ACTION_REQUIRED
```

### 4. Mission Control Injection (Action Required)

**IF `HIGH` or `CRITICAL` vulnerabilities are found:**

Create a new task card using mc-api:

```bash
/workspace/.mc-api-backup create-task \
  --title "[URGENT] Patch Nightly Scan Vulnerability: <Vulnerability Name>" \
  --description "File: <path>\nLines: <line numbers>\nSeverity: <level>\nRemediation: <tool advice>" \
  --column "Backlog" \
  --tags "Security,Sprint-Blocker"
```

**IF NO high-level vulnerabilities are found:**
Do nothing on the board. Log "CLEAN" status only.

### 5. Cleanup
Delete temporary scan output files to keep the workspace clean:

```bash
rm -f workspace/reports/semgrep_out.txt
rm -f workspace/reports/bandit_out.json
rm -f workspace/reports/grep_audit.txt
```

The `DAILY_SECURITY_LOG.md` is permanent and must NOT be deleted.

## Error Handling
- If no scanner is available, use grep-based fallback and log `[SCANNER-MISSING]`.
- If Mission Control is offline, write findings to `workspace/reports/PENDING_SECURITY_TASKS.md` for manual import.
- If `src/` directory doesn't exist, scan the workspace root instead.

## Dependencies
- `/workspace/.mc-api-backup` — Mission Control CLI
- `semgrep` or `bandit` or `grep` — Security scanner (at least grep is always available)
- `workspace/reports/DAILY_SECURITY_LOG.md` — Append-only security log

