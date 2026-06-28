#!/usr/bin/env bash
# PreToolUse hook for Write/Edit/MultiEdit — blocks writes to secret files and warns on hardcoded secrets in source.

FILE="${CLAUDE_TOOL_INPUT_FILE_PATH:-}"
CONTENT="${CLAUDE_TOOL_INPUT_CONTENT:-}"

if [[ -z "$FILE" ]]; then
  exit 0
fi

# Hard block: never write .env files
if echo "$FILE" | grep -qE '(^|/)\.env(\.[A-Za-z0-9]+)?$'; then
  echo "[env-guard] BLOCKED: $FILE is a secret file and must not be written by tools." >&2
  echo "[env-guard] Edit it manually, or update .env.example instead." >&2
  exit 1
fi

# Hard block: never write GoogleService-Info.plist (Firebase config)
if echo "$FILE" | grep -qE 'GoogleService-Info\.plist$'; then
  echo "[env-guard] BLOCKED: GoogleService-Info.plist must not be written by tools. Manage via Firebase Console." >&2
  exit 1
fi

# Only scan source files for hardcoded secrets
if ! echo "$FILE" | grep -qE '\.(swift|plist|json|xcconfig)$'; then
  exit 0
fi

if [[ -z "$CONTENT" ]]; then
  exit 0
fi

WARNINGS=()

# Firebase API key pattern (AIza...)
if echo "$CONTENT" | grep -qE '"AIza[A-Za-z0-9_-]{35}"'; then
  WARNINGS+=("hardcoded Firebase API key — use APIConfiguration or load from secure config")
fi

# Long hex tokens (>= 32 chars) that look like Bearer tokens
if echo "$CONTENT" | grep -qE '["'"'"'][0-9a-fA-F]{32,}["'"'"']'; then
  WARNINGS+=("long hex literal — possible hardcoded token; load from Keychain or APIConfiguration")
fi

# Hardcoded http/https URLs outside of APIConfiguration
if echo "$FILE" | grep -qvE 'APIConfiguration'; then
  if echo "$CONTENT" | grep -qE '"https?://[^"]{10,}"'; then
    WARNINGS+=("hardcoded URL string — define endpoints in APIConfiguration (see AGENTS.md §Networking)")
  fi
fi

# UserDefaults for sensitive data
if echo "$CONTENT" | grep -qE 'UserDefaults.*set\(.*token|UserDefaults.*set\(.*key|UserDefaults.*set\(.*secret|UserDefaults.*set\(.*password'; then
  WARNINGS+=("sensitive data in UserDefaults — use Keychain instead (see anti-patterns/keychain-vs-userdefaults.md)")
fi

if [[ ${#WARNINGS[@]} -gt 0 ]]; then
  echo "[env-guard] WARNING: possible secret hardcoded in $FILE." >&2
  for w in "${WARNINGS[@]}"; do
    echo "  ⚠ $w" >&2
  done
  echo "[env-guard] Secrets must come from Keychain or APIConfiguration. See AGENTS.md §Networking and rules/common/security.md." >&2
fi

exit 0
