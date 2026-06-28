#!/bin/bash
# PreToolUse hook untuk Write/Edit/MultiEdit — peringatkan pelanggaran design token

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('file_path', d.get('path','')))" 2>/dev/null || echo "")
CONTENT=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('content', d.get('new_string','')))" 2>/dev/null || echo "")

# Hanya periksa file Swift
if ! echo "$FILE_PATH" | grep -qE '\.swift$'; then
  exit 0
fi

WARNINGS=()

# Hardcoded hex color
if echo "$CONTENT" | grep -qE 'Color\(hex:\s*"#[0-9A-Fa-f]'; then
  WARNINGS+=("⚠️  Ditemukan Color(hex:) — gunakan JedaColor dari JedaTheme.swift")
fi

# Hardcoded literal hex di comment/string (di luar Color(hex:))
if echo "$CONTENT" | grep -qE '"#[0-9A-Fa-f]{6}"'; then
  WARNINGS+=("⚠️  Ditemukan hardcoded hex color string — gunakan JedaColor dari JedaTheme.swift")
fi

# Hardcoded font size
if echo "$CONTENT" | grep -qE '\.system\(size:\s*[0-9]'; then
  WARNINGS+=("⚠️  Ditemukan .system(size:) — gunakan .font(.body/.headline/dll) untuk Dynamic Type support")
fi

# Force unwrap di non-test file
if ! echo "$FILE_PATH" | grep -qiE '(Tests?|Spec|Mock)'; then
  if echo "$CONTENT" | grep -qE '[^!]![^=!]' && echo "$CONTENT" | grep -qE '\)!|]!'; then
    WARNINGS+=("⚠️  Ditemukan kemungkinan force unwrap (!) di production code — gunakan guard/if let")
  fi
fi

if [ ${#WARNINGS[@]} -gt 0 ]; then
  echo "" >&2
  echo "🟡 TOKEN GUARD — Jeda iOS" >&2
  echo "File: $FILE_PATH" >&2
  for warning in "${WARNINGS[@]}"; do
    echo "  $warning" >&2
  done
  echo "" >&2
  echo "Pertimbangkan untuk memperbaiki sebelum melanjutkan." >&2
  echo "" >&2
fi

exit 0
