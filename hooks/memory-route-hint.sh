#!/bin/sh
# UserPromptSubmit: deterministic routing layer for auto-memory.
# Matches prompt keywords against memory/INDEX.md rows and emits a one-line
# hint pointing at the docs to Read — never injects document bodies.
# ASCII keywords require word boundaries (avoids "test" matching "latest",
# "ui" matching "build"); Korean keywords match as substrings (particles attach).
IN=$(cat)
PROMPT=$(printf '%s' "$IN" | jq -r '.prompt // empty' 2>/dev/null)
P="${CLAUDE_PROJECT_DIR:-.}"
IDX="$P/memory/INDEX.md"
{ [ -n "$PROMPT" ] && [ -f "$IDX" ]; } || exit 0

match_kw() {
  if printf '%s' "$1" | grep -q '^[A-Za-z0-9]\{1,\}$'; then
    PAT="(^|[^[:alnum:]])$1([^[:alnum:]]|\$)"
    printf '%s' "$PROMPT" | grep -qiE "$PAT"
  else
    printf '%s' "$PROMPT" | grep -qiF -- "$1"
  fi
}

grep '^|' "$IDX" | tail -n +3 | while IFS='|' read -r _ TYPE KWS FILES _; do
  KWS=$(printf '%s' "$KWS" | tr -d ' ')
  [ -n "$KWS" ] || continue
  OLDIFS=$IFS; IFS=','
  for kw in $KWS; do
    if [ -n "$kw" ] && match_kw "$kw"; then
      TYPE_TRIM=$(printf '%s' "$TYPE" | sed 's/^ *//;s/ *$//')
      FILES_TRIM=$(printf '%s' "$FILES" | sed 's/^ *//;s/ *$//')
      printf '[auto-memory] "%s" 유형 작업으로 보임 → 시작 전 Read: %s\n' "$TYPE_TRIM" "$FILES_TRIM"
      break
    fi
  done
  IFS=$OLDIFS
done
exit 0
