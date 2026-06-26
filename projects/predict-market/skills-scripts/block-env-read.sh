#!/usr/bin/env bash
#
# block-env-read.sh — PreToolUse hook：阻擋讀取 .env 內容的操作
#
# 對應 CLAUDE.md「`.env` 嚴格保密」核心硬性規則。
# 應用程式（runner.ts、Laravel）內部 dotenv.config() 呼叫不經此 hook，自然不受影響。

set -euo pipefail

input=$(cat)
tool_name=$(printf '%s' "$input" | jq -r '.tool_name // ""')

deny() {
  local reason="$1"
  jq -n --arg reason "$reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

is_sensitive_env_path() {
  local s="$1"
  if printf '%s' "$s" | grep -qE '\.env\.(example|template|sample|dist)\b'; then
    return 1
  fi
  if printf '%s' "$s" | grep -qE '(^|[/[:space:]"=])\.env([[:space:]]|$|"|/|\.local\b|\.[^.[:space:]"]+\.local\b)'; then
    return 0
  fi
  return 1
}

case "$tool_name" in
  Read)
    file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // ""')
    if is_sensitive_env_path "$file_path"; then
      deny "拒絕 Read .env 檔案內容（CLAUDE.md 安全規則）。需驗證變數存在請改用 Bash: grep -c '^VAR=' .env"
    fi
    ;;

  Bash)
    command=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')

    if ! printf '%s' "$command" | grep -qE '\.env\b'; then
      exit 0
    fi

    if ! is_sensitive_env_path "$command"; then
      exit 0
    fi

    if printf '%s' "$command" | grep -qE '(^|[[:space:]|;&(])(cat|head|tail|less|more|bat|sed)([[:space:]]|$)'; then
      deny "拒絕用 cat/head/tail/less/more/bat/sed 印 .env 內容（CLAUDE.md 安全規則）。需驗證變數存在請用：grep -c '^VAR=' .env"
    fi

    if printf '%s' "$command" | grep -qE '(^|[[:space:]|;&(])awk([[:space:]]|$)'; then
      if ! printf '%s' "$command" | grep -qE 'length\([^)]*\)'; then
        deny "拒絕用 awk 印 .env 內容（CLAUDE.md 安全規則）。只取長度請用：awk -F= '/^VAR=/ { print length(\$2) }' .env"
      fi
    fi

    if printf '%s' "$command" | grep -qE '(^|[[:space:]|;&(])grep([[:space:]]|$)'; then
      if ! printf '%s' "$command" | grep -qE 'grep[[:space:]]+(-[a-zA-Z]*c\b|--count\b)'; then
        deny "拒絕用 grep 印 .env 內容（CLAUDE.md 安全規則）。只算 count 請加 -c 旗標：grep -c '^VAR=' .env"
      fi
    fi

    if printf '%s' "$command" | grep -qE '<[[:space:]]*[^[:space:]]*\.env\b|(^|[[:space:]|;&(])(source|\.)[[:space:]]+[^[:space:]]*\.env\b'; then
      deny "拒絕用 shell redirection / source 載入 .env（CLAUDE.md 安全規則）。應用程式請用 dotenv.config() 直接讀。"
    fi
    ;;
esac

exit 0
