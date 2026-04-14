#!/bin/bash
# Auto-format edited files
# Detecta prettier o biome
# Solo formatea: .ts, .js, .tsx, .jsx, .css, .json, .md
# Usage: ~/.claude/hooks/auto-format.sh <file_path>

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
BASE_NAME=$(basename "$FILE_PATH")

# Check if file is a supported type
SUPPORTED_EXTENSIONS="ts js tsx jsx css json md"
if ! echo "$SUPPORTED_EXTENSIONS" | grep -q "\b$EXT\b"; then
  echo "Skipping $BASE_NAME - not a supported format"
  exit 0
fi

# Detect formatter (prefer prettier over biome)
FORMATTER=""
if command -v prettier &> /dev/null; then
  FORMATTER="prettier"
elif command -v biome &> /dev/null; then
  FORMATTER="biome"
fi

if [ -z "$FORMATTER" ]; then
  echo "No formatter found (prettier or biome)"
  exit 0
fi

# Get the directory of the file to look for config
FILE_DIR=$(dirname "$FILE_PATH")

echo "Formatting $BASE_NAME with $FORMATTER..."

case "$FORMATTER" in
  prettier)
    prettier --write "$FILE_PATH"
    ;;
  biome)
    biome format --write "$FILE_PATH"
    ;;
esac

echo "Done formatting $BASE_NAME"
