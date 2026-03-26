#!/bin/bash
# WorktreeCreate/WorktreeRemove: 워크트리 라이프사이클 추적
# autodev-parallel에서 고아 워크트리 방지
set -euo pipefail

EVENT="${CLAUDE_HOOK_EVENT:-unknown}"
WORKTREE_PATH="${CLAUDE_WORKTREE_PATH:-unknown}"
BRANCH="${CLAUDE_WORKTREE_BRANCH:-unknown}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S")
TRACKER=".worktree-tracker.log"

case "$EVENT" in
  WorktreeCreate)
    echo "[$TIMESTAMP] CREATE $BRANCH -> $WORKTREE_PATH" >> "$TRACKER" 2>/dev/null || true
    # AUDIT.log에 기록
    if [ -f "AUDIT.log" ]; then
      echo "[$TIMESTAMP] system WORKTREE_CREATE $BRANCH" >> "AUDIT.log"
    fi
    ;;
  WorktreeRemove)
    echo "[$TIMESTAMP] REMOVE $BRANCH <- $WORKTREE_PATH" >> "$TRACKER" 2>/dev/null || true
    if [ -f "AUDIT.log" ]; then
      echo "[$TIMESTAMP] system WORKTREE_REMOVE $BRANCH" >> "AUDIT.log"
    fi
    # .active-agents에서 관련 에이전트 제거
    if [ -f ".active-agents" ]; then
      grep -v "$BRANCH" ".active-agents" > ".active-agents.tmp" 2>/dev/null && mv ".active-agents.tmp" ".active-agents" || true
    fi
    ;;
esac

exit 0
