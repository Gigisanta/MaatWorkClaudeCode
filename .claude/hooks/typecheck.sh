#!/bin/bash
# Run TypeScript check after editing .ts/.tsx
# Usage: ~/.claude/hooks/typecheck.sh <file_path>
# Solo corre si existe tsconfig.json en el proyecto

set -e

FILE_PATH="$1"

if [ -z "$FILE_PATH" ]; then
  echo "Usage: $0 <file_path>"
  exit 1
fi

if [ ! -f "$FILE_PATH" ]; then
  echo "File not found: $FILE_PATH"
  exit 1
fi

# Extract file extension
EXT="${FILE_PATH##*.}"

# Only run for TypeScript files
if [ "$EXT" != "ts" ] && [ "$EXT" != "tsx" ]; then
  echo "Skipping $FILE_PATH - not a TypeScript file"
  exit 0
fi

# Find tsconfig.json starting from file directory up to root
SEARCH_DIR=$(dirname "$FILE_PATH")
while [ "$SEARCH_DIR" != "/" ]; do
  if [ -f "$SEARCH_DIR/tsconfig.json" ]; then
    echo "Found tsconfig.json at $SEARCH_DIR"
    break
  fi
  SEARCH_DIR=$(dirname "$SEARCH_DIR")
done

if [ ! -f "$SEARCH_DIR/tsconfig.json" ]; then
  echo "No tsconfig.json found - skipping type check"
  exit 0
fi

# Check if tsc is available
if ! command -v tsc &> /dev/null; then
  echo "TypeScript compiler (tsc) not found"
  exit 0
fi

echo "Running TypeScript check for $FILE_PATH..."

# Run type check on the file
tsc --noEmit --pretty "$FILE_PATH" 2>&1

echo "TypeScript check completed"
