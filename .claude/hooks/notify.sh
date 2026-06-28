#!/bin/bash
# Notification hook — kirim macOS desktop notification

INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('message','Jeda iOS — Claude selesai'))" 2>/dev/null || echo "Jeda iOS — Claude selesai")

osascript -e "display notification \"$MESSAGE\" with title \"Jeda iOS\" subtitle \"Claude Code\"" 2>/dev/null || true

exit 0
