#!/bin/bash
# PreToolUse hook untuk Write/Edit/MultiEdit — blokir penulisan ke file generated/protected

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('file_path', d.get('path','')))" 2>/dev/null || echo "")

# Blokir Xcode project file
if echo "$FILE_PATH" | grep -q 'project.pbxproj'; then
  echo "🚫 BLOCKED: project.pbxproj dikelola Xcode secara otomatis. Jangan edit manual." >&2
  exit 2
fi

# Blokir Firebase config
if echo "$FILE_PATH" | grep -q 'GoogleService-Info.plist'; then
  echo "🚫 BLOCKED: GoogleService-Info.plist adalah file konfigurasi sensitif. Edit via Firebase Console." >&2
  exit 2
fi

# Blokir Core ML binary model
if echo "$FILE_PATH" | grep -qE 'Resources/Models/.*\.(mlpackage|mlmodelc)'; then
  echo "🚫 BLOCKED: File Core ML model adalah binary yang dikelola Xcode. Jangan edit manual." >&2
  exit 2
fi

# Blokir SSOT dan AGENTS
if echo "$FILE_PATH" | grep -qE '(SSOT\.md|AGENTS\.md)$'; then
  echo "🚫 BLOCKED: $FILE_PATH hanya boleh diubah oleh developer, bukan Claude." >&2
  exit 2
fi

exit 0
