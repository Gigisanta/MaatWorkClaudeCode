#!/bin/bash
# Detect hardcoded secrets before git operations
# Patterns: api_key, secret, password, token, aws_access_key, private_key
# Usage: ~/.claude/hooks/secrets-detector.sh git
# Return: exit 1 si encuentra secretos

set -e

MODE="$1"

if [ -z "$MODE" ]; then
  echo "Usage: $0 git|file <path>"
  exit 1
fi

# Secret patterns to detect
PATTERNS=(
  "api[_-]?key"
  "secret"
  "password"
  "token"
  "aws[_-]?access[_-]?key"
  "private[_-]?key"
  "bearer"
  "auth"
)

# Files/directories to ignore
IGNORE_PATTERNS=(
  "node_modules"
  ".git"
  ".next"
  "dist"
  "build"
  "coverage"
  ".env"
  ".env.example"
  "package-lock.json"
  "yarn.lock"
  "pnpm-lock.yaml"
)

FOUND_SECRETS=0

scan_file() {
  local FILE="$1"

  # Check if file should be ignored
  for IGNORE in "${IGNORE_PATTERNS[@]}"; do
    if echo "$FILE" | grep -q "$IGNORE"; then
      return 0
    fi
  done

  # Scan file for secret patterns
  for PATTERN in "${PATTERNS[@]}"; do
    # Use case-insensitive grep, but avoid flag warnings
    if grep -iE "[=:]\s*['\"]?[A-Za-z0-9/+_-]{20,}['\"]?" "$FILE" 2>/dev/null | grep -iE "$PATTERN" > /dev/null 2>&1; then
      echo "WARNING: Potential secret pattern '$PATTERN' found in: $FILE"
      FOUND_SECRETS=1
    fi
  done
}

if [ "$MODE" = "git" ]; then
  # Get list of staged and modified files
  echo "Scanning for hardcoded secrets..."

  # Check staged files
  if command -v git &> /dev/null; then
    # Get staged files
    STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || true)
    for FILE in $STAGED_FILES; do
      scan_file "$FILE"
    done

    # Get modified files (not staged)
    MODIFIED_FILES=$(git diff --name-only 2>/dev/null || true)
    for FILE in $MODIFIED_FILES; do
      scan_file "$FILE"
    done
  fi
elif [ "$MODE" = "file" ]; then
  FILE_PATH="$2"
  if [ -z "$FILE_PATH" ]; then
    echo "Usage: $0 file <path>"
    exit 1
  fi
  scan_file "$FILE_PATH"
fi

if [ $FOUND_SECRETS -eq 1 ]; then
  echo ""
  echo "ERROR: Hardcoded secrets detected!"
  echo "Please remove secrets before committing."
  exit 1
fi

echo "No hardcoded secrets detected"
exit 0
