#!/bin/bash

# Claude Code Configuration Installer
# https://github.com/jh941213/my-claude-code-asset

set -e

echo "Claude Code Power Pack 설치 시작..."

# 임시 디렉토리에 클론
TEMP_DIR=$(mktemp -d)
git clone --depth 1 https://github.com/jh941213/my-claude-code-asset.git "$TEMP_DIR"

# ~/.claude 디렉토리 생성
mkdir -p ~/.claude/agents ~/.claude/skills ~/.claude/rules ~/.claude/commands ~/.claude/team-roles ~/.claude/hooks

# 파일 복사
echo "설정 파일 복사 중..."

# CLAUDE.md 복사
if [ -f "$TEMP_DIR/CLAUDE.md" ]; then
    cp "$TEMP_DIR/CLAUDE.md" ~/.claude/
    echo "   CLAUDE.md"
fi

# settings.json 복사
if [ -f "$TEMP_DIR/settings.json" ]; then
    cp "$TEMP_DIR/settings.json" ~/.claude/
    echo "   settings.json"
fi

# agents 복사
if [ -d "$TEMP_DIR/agents" ]; then
    cp "$TEMP_DIR/agents/"*.md ~/.claude/agents/ 2>/dev/null || true
    echo "   agents/ (10개)"
fi

# skills 복사
if [ -d "$TEMP_DIR/skills" ]; then
    cp -r "$TEMP_DIR/skills/"* ~/.claude/skills/ 2>/dev/null || true
    echo "   skills/ (32개)"
fi

# rules 복사
if [ -d "$TEMP_DIR/rules" ]; then
    cp "$TEMP_DIR/rules/"*.md ~/.claude/rules/ 2>/dev/null || true
    echo "   rules/ (5개, 조건부 로드)"
fi

# commands 복사
if [ -d "$TEMP_DIR/commands" ]; then
    cp "$TEMP_DIR/commands/"*.md ~/.claude/commands/ 2>/dev/null || true
    echo "   commands/ (3개)"
fi

# team-roles 복사 (TTH)
if [ -d "$TEMP_DIR/team-roles" ]; then
    cp "$TEMP_DIR/team-roles/"*.md ~/.claude/team-roles/ 2>/dev/null || true
    echo "   team-roles/ (5개 CEO 페르소나)"
fi

# hooks 복사 (TTH)
if [ -d "$TEMP_DIR/hooks" ]; then
    cp "$TEMP_DIR/hooks/"*.sh ~/.claude/hooks/ 2>/dev/null || true
    chmod +x ~/.claude/hooks/*.sh 2>/dev/null || true
    echo "   hooks/ (2개 품질 게이트)"
fi

# 정리
rm -rf "$TEMP_DIR"

echo ""
echo "설치 완료!"
echo ""
echo "설치된 위치: ~/.claude/"
echo ""
echo "설치된 항목:"
echo "   - CLAUDE.md (논문 기반 최적화 94줄)"
echo "   - settings.json (권한 + Hooks 보장 + Agent Teams)"
echo "   - agents/ (10개 에이전트)"
echo "   - skills/ (32개 스킬)"
echo "   - rules/ (5개, YAML 조건부 로드)"
echo "   - commands/ (3개 슬래시 커맨드)"
echo "   - team-roles/ (5개 TTH CEO 페르소나)"
echo "   - hooks/ (2개 품질 게이트)"
echo ""
echo "TTH 멀티 에이전트 (NEW):"
echo "   /tth [설명]      -> M7 CEO 팀이 자율 협업 (Toss+Tesla+Ralph)"
echo ""
echo "기존 워크플로우:"
echo "   /prd [아이디어]   -> PRD.md (인사이트 중심 기획)"
echo "   /docs             -> /docs/ 자동 문서 생성"
echo "   /plan, /spec, /spec-verify, /frontend, /verify, /e2e-verify"
echo "   /commit-push-pr, /review, /simplify, /tdd"
echo "   /build-fix, /handoff, /compact-guide, /techdebt"
echo ""
echo "플러그인 방식 설치 (권장):"
echo "   claude plugin marketplace add jh941213/my-claude-code-asset"
echo "   claude plugin install ccpp@my-claude-code-asset"
echo ""
