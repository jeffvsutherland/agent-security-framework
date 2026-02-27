#!/bin/bash
# Batch update story points for ASF project

echo "🚀 Batch Updating ASF Story Points"
echo "=================================="

# Known completed stories with their points from sprint documentation
echo "✅ Updating completed stories with documented points..."

./jira-update-points.sh update ASF-9 5    # Port Scan Detection (from sprint docs)
./jira-update-points.sh update ASF-10 3   # Community Spam Detection (from sprint docs)
./jira-update-points.sh update ASF-11 2   # Infrastructure Security (from sprint docs)

# Other completed stories - estimating based on effort
echo -e "\n✅ Updating other completed stories..."

./jira-update-points.sh update ASF-1 8    # skill-evaluator.sh (already done)
./jira-update-points.sh update ASF-17 3   # Blog post writing
./jira-update-points.sh update ASF-19 3   # LinkedIn Content Strategy

# Tasks (typically no story points, but adding small values)
echo -e "\n📋 Updating tasks..."

./jira-update-points.sh update ASF-7 1    # Account Lockout task
./jira-update-points.sh update ASF-8 1    # Service Inquiry task

# To Do stories - estimating based on complexity
echo -e "\n📝 Updating To Do stories with estimates..."

./jira-update-points.sh update ASF-2 8    # Docker container templates (complex)
./jira-update-points.sh update ASF-3 5    # ASA vulnerability database (medium)
./jira-update-points.sh update ASF-4 3    # Document deployment guide (documentation)
./jira-update-points.sh update ASF-5 8    # YARA rules implementation (complex)
./jira-update-points.sh update ASF-6 5    # Community testing framework (medium)
./jira-update-points.sh update ASF-18 3   # Code review process (process doc)

echo -e "\n✅ Batch update complete!"
echo ""
echo "Summary of updates:"
echo "==================="
echo "ASF-1:  8 points (skill-evaluator.sh)"
echo "ASF-2:  8 points (Docker templates)"
echo "ASF-3:  5 points (Vulnerability DB)"
echo "ASF-4:  3 points (Deployment guide)"
echo "ASF-5:  8 points (YARA rules)"
echo "ASF-6:  5 points (Testing framework)"
echo "ASF-7:  1 point  (Task: Account lockout)"
echo "ASF-8:  1 point  (Task: Service inquiry)"
echo "ASF-9:  5 points (Port scan detection) ✓"
echo "ASF-10: 3 points (Spam detection) ✓"
echo "ASF-11: 2 points (Infrastructure security) ✓"
echo "ASF-17: 3 points (Blog post) ✓"
echo "ASF-18: 3 points (Code review process)"
echo "ASF-19: 3 points (LinkedIn strategy) ✓"
echo ""
echo "Total points assigned: 68"
echo "(✓ = completed stories)"