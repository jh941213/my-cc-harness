#!/bin/bash
# 홈 디렉토리에서 세션 시작 시 auto-memory를 기본 템플릿으로 리셋
# 프로젝트 디렉토리에서는 아무 동작 안 함

CWD="${CLAUDE_CWD:-$(pwd)}"
HOME_DIR="$HOME"

# 홈 디렉토리 정확히 일치할 때만 리셋 (하위 경로 X)
if [ "$CWD" = "$HOME_DIR" ] || [ "$CWD" = "$HOME_DIR/" ]; then
  MEMORY_DIR="$HOME/.claude/projects/-Users-kdb/memory"
  MEMORY_FILE="$MEMORY_DIR/MEMORY.md"

  if [ -d "$MEMORY_DIR" ]; then
    # MEMORY.md를 기본 템플릿으로 리셋
    cat > "$MEMORY_FILE" << 'EOF'
## Feedback
- [feedback_caching.md](feedback_caching.md) — 세션 중 캐시 보존 규칙 (설정/모델/도구 변경 금지)
EOF

    # feedback_caching.md 외의 임시 메모리 파일 정리
    find "$MEMORY_DIR" -name "*.md" \
      ! -name "MEMORY.md" \
      ! -name "feedback_caching.md" \
      -newer "$MEMORY_DIR/feedback_caching.md" \
      -delete 2>/dev/null
  fi
fi

exit 0
