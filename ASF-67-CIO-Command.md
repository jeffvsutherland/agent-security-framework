# ASF-67: Simple CIO Command for ASF Report

**Status:** REVIEW  
**Assignee:** Research Agent  
**Date:** March 13, 2026

---

## Description

Create a simple CLI command to generate the CIO security report on demand.

## Command

```bash
# Generate CIO Report
./asf-cio-report.sh --format=markdown --output=CIO-Report.md

# With date
./asf-cio-report.sh --date=2026-03-13
```

---

## DoD

- [x] Command created
- [x] Tested
- [x] Ready for use

---

## See Also

- [CIO Report](./docs/deliverables/ASF-52-CIO-Security-Report.md)
