#!/bin/bash
# Post-edit quality check hook
# Reads tool input from stdin, runs appropriate linter based on file extension

FILE_PATH=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

case "$FILE_PATH" in
  */frontend/*.ts|*/frontend/*.tsx)
    cd "$CLAUDE_PROJECT_DIR/frontend" && npx tsc --noEmit 2>&1 | head -20
    ;;
  */backend/*.php)
    # PHP lint via Docker container (backend runs in Docker)
    RELATIVE_PATH="${FILE_PATH#$CLAUDE_PROJECT_DIR/backend/}"
    docker compose -f "$CLAUDE_PROJECT_DIR/docker/docker-compose.yml" exec -T app php -l "/var/www/html/$RELATIVE_PATH" 2>&1
    ;;
esac
