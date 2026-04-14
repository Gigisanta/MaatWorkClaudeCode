#!/bin/bash
# Log executed bash commands with timestamp
# Usage: ~/.claude/hooks/log-commands.sh

CMD="$*"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] $CMD"
exit 0
