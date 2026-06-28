#!/usr/bin/env bash
# PreToolUse hook for Bash — blocks dangerous operations and enforces RTK.

COMMAND="${CLAUDE_TOOL_INPUT_COMMAND:-}"

# Block rm -rf
if echo "$COMMAND" | grep -qE 'rm\s+-rf'; then
  if echo "$COMMAND" | grep -qE '(Jeda/|\.claude/|AGENTS\.md|SSOT\.md|PRODUCT\.md|/\s*$|\.\s*$|\.\.\s*$|\*)'; then
    echo "[safety] BLOCKED: rm -rf on protected path: $COMMAND" >&2
    exit 1
  fi
fi

# Block git push directly to main
if echo "$COMMAND" | grep -qE 'git\s+push\s+(origin\s+)?main'; then
  echo "[safety] BLOCKED: git push to main is not allowed. Create a PR via /create-pr." >&2
  exit 1
fi

# Block shell redirection writes to .env files
if echo "$COMMAND" | grep -qE '(>|>>|tee)\s+\.env'; then
  echo "[safety] BLOCKED: writing to .env files via shell redirection." >&2
  exit 1
fi

# Block manual edits to project.pbxproj
if echo "$COMMAND" | grep -q 'project.pbxproj'; then
  echo "[safety] BLOCKED: project.pbxproj is managed by Xcode. Do not edit manually." >&2
  exit 1
fi

# Remind RTK enforcement for Xcode/Swift commands without rtk prefix
if echo "$COMMAND" | grep -qE '(^|\s|;|&&|\|)\s*(xcodebuild|swiftlint|xcrun)\b' \
  && ! echo "$COMMAND" | grep -qE '(^|\s|;|&&|\|)\s*rtk\b'; then
  echo "[safety] REMINDER: prefix terminal commands with 'rtk' (see CLAUDE.md §RTK Enforcement)." >&2
fi

exit 0
