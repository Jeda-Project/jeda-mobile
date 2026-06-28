#!/bin/bash
# PostToolUse hook untuk Write/Edit/MultiEdit — jalankan SwiftLint jika tersedia

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('file_path', d.get('path','')))" 2>/dev/null || echo "")

# Hanya proses file Swift
if ! echo "$FILE_PATH" | grep -qE '\.swift$'; then
  exit 0
fi

# Cek apakah SwiftLint tersedia
if ! command -v swiftlint &> /dev/null; then
  echo "ℹ️  SwiftLint tidak tersedia. Install via: brew install swiftlint" >&2
  exit 0
fi

# Jalankan SwiftLint pada file yang dimodifikasi
OUTPUT=$(swiftlint lint --quiet --path "$FILE_PATH" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ] || [ -n "$OUTPUT" ]; then
  echo "" >&2
  echo "🔍 SwiftLint — $FILE_PATH" >&2
  echo "$OUTPUT" >&2
  echo "" >&2
fi

exit 0
