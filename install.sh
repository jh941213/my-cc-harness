#!/bin/bash

# Claude Code Configuration Installer
# https://github.com/jh941213/my-claude-code-asset

set -e

echo "🚀 Claude Code Power Pack 설치 시작..."

# 임시 디렉토리에 클론
TEMP_DIR=$(mktemp -d)
git clone --depth 1 https://github.com/jh941213/my-claude-code-asset.git "$TEMP_DIR"

# ~/.claude 디렉토리 생성
mkdir -p ~/.claude/agents ~/.claude/skills ~/.claude/rules

# 파일 복사
echo "📁 설정 파일 복사 중..."

# CLAUDE.md 복사
if [ -f "$TEMP_DIR/CLAUDE.md" ]; then
    cp "$TEMP_DIR/CLAUDE.md" ~/.claude/
    echo "   ✔ CLAUDE.md"
fi

# settings.json 복사
if [ -f "$TEMP_DIR/settings.json" ]; then
    cp "$TEMP_DIR/settings.json" ~/.claude/
    echo "   ✔ settings.json"
fi

# agents 복사
if [ -d "$TEMP_DIR/agents" ]; then
    cp "$TEMP_DIR/agents/"*.md ~/.claude/agents/ 2>/dev/null || true
    echo "   ✔ agents/"
fi

# skills 복사
if [ -d "$TEMP_DIR/skills" ]; then
    cp -r "$TEMP_DIR/skills/"* ~/.claude/skills/ 2>/dev/null || true
    echo "   ✔ skills/"
fi

# rules 복사
if [ -d "$TEMP_DIR/rules" ]; then
    cp "$TEMP_DIR/rules/"*.md ~/.claude/rules/ 2>/dev/null || true
    echo "   ✔ rules/"
fi

# 정리
rm -rf "$TEMP_DIR"

echo ""
echo "✅ 설치 완료!"
echo ""
echo "📂 설치된 위치: ~/.claude/"
echo ""
echo "📋 설치된 항목:"
echo "   - CLAUDE.md (전역 설정)"
echo "   - settings.json (권한/Hooks)"
echo "   - agents/ (6개 에이전트)"
echo "   - skills/ (23개 스킬)"
echo "   - rules/ (5개 규칙)"
echo ""
echo "🎯 사용 가능한 워크플로우 스킬:"
echo "   /plan, /spec, /spec-verify, /frontend, /verify"
echo "   /commit-push-pr, /review, /simplify, /tdd"
echo "   /build-fix, /handoff, /compact-guide, /techdebt"
echo ""
echo "💡 플러그인 방식 설치 (권장):"
echo "   claude plugin marketplace add jh941213/my-claude-code-asset"
echo "   claude plugin install ccpp@my-claude-code-asset"
echo ""
echo "💡 터미널 alias 추가하려면:"
echo '   echo '\''alias c="claude"'\'' >> ~/.zshrc && source ~/.zshrc'
echo ""
