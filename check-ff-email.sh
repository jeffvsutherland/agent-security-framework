#!/bin/bash
# Check Frequency Foundation email using Himalaya
# Usage: ./check-ff-email.sh [page-size]

PAGE_SIZE=${1:-5}

echo "📧 Checking drjeffsutherland@frequencyfoundation.com..."
echo "----------------------------------------"

himalaya envelope list -a frequencyfoundation --page-size $PAGE_SIZE 2>&1 | grep -v "WARN"

echo ""
echo "✅ Email check complete"

