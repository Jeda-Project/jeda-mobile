#!/bin/bash
# Stop hook — tampilkan session summary saat Claude berhenti

echo ""
echo "══════════════════════════════════════════"
echo "  📱 Jeda iOS — Session Summary"
echo "══════════════════════════════════════════"
echo ""

# File yang dimodifikasi dalam sesi ini
MODIFIED=$(git diff --name-only 2>/dev/null)
STAGED=$(git diff --cached --name-only 2>/dev/null)

if [ -n "$STAGED" ]; then
  echo "📦 File staged (siap commit):"
  echo "$STAGED" | sed 's/^/   /'
  echo ""
fi

if [ -n "$MODIFIED" ]; then
  echo "✏️  File dimodifikasi (belum staged):"
  echo "$MODIFIED" | sed 's/^/   /'
  echo ""
fi

if [ -z "$STAGED" ] && [ -z "$MODIFIED" ]; then
  echo "✅ Tidak ada perubahan uncommitted."
  echo ""
fi

# Checklist pre-commit
echo "📋 Pre-Commit Checklist:"
echo "   □ Build berhasil? (rtk xcodebuild build ...)"
echo "   □ Tidak ada SwiftUI import di Services layer?"
echo "   □ Tidak ada hardcoded warna hex?"
echo "   □ Semua interactive element punya accessibilityLabel?"
echo "   □ Tidak ada force unwrap baru di production code?"
echo "   □ Commit message mengikuti conventional commits?"
echo ""
echo "══════════════════════════════════════════"
echo ""

exit 0
