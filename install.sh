#!/bin/bash

# Claude Code Configuration Installer
# https://github.com/jh941213/my-cc-harness

set -e

# Language selection
LANG_CHOICE=""
if [ "$1" = "--en" ] || [ "$1" = "--english" ]; then
    LANG_CHOICE="en"
elif [ "$1" = "--ko" ] || [ "$1" = "--korean" ]; then
    LANG_CHOICE="ko"
fi

if [ -z "$LANG_CHOICE" ]; then
    echo ""
    echo "Select language / 언어를 선택하세요:"
    echo "  1) English"
    echo "  2) 한국어 (Korean)"
    echo ""
    read -p "Enter choice (1 or 2): " lang_input
    case "$lang_input" in
        1|en|english|EN|English) LANG_CHOICE="en" ;;
        *) LANG_CHOICE="ko" ;;
    esac
fi

if [ "$LANG_CHOICE" = "en" ]; then
    echo "Starting My CC Harness installation (English)..."
else
    echo "My CC Harness 설치 시작..."
fi

# Clone to temp directory
TEMP_DIR=$(mktemp -d)
git clone --depth 1 https://github.com/jh941213/my-cc-harness.git "$TEMP_DIR"

# Create ~/.claude directories
mkdir -p ~/.claude/agents ~/.claude/skills ~/.claude/rules ~/.claude/commands ~/.claude/team-roles ~/.claude/hooks ~/.claude/scripts ~/.claude/templates ~/.claude/semgrep-rules

# Determine source suffix
if [ "$LANG_CHOICE" = "en" ]; then
    AGENTS_SRC="agents_en"
    SKILLS_SRC="skills_en"
    RULES_SRC="rules_en"
    COMMANDS_SRC="commands_en"
    TEAM_ROLES_SRC="team-roles_en"
    CLAUDE_MD_SRC="CLAUDE_EN.md"
else
    AGENTS_SRC="agents"
    SKILLS_SRC="skills"
    RULES_SRC="rules"
    COMMANDS_SRC="commands"
    TEAM_ROLES_SRC="team-roles"
    CLAUDE_MD_SRC="CLAUDE.md"
fi

# Copy files
if [ "$LANG_CHOICE" = "en" ]; then
    echo "Copying configuration files..."
else
    echo "설정 파일 복사 중..."
fi

# CLAUDE.md
if [ -f "$TEMP_DIR/$CLAUDE_MD_SRC" ]; then
    cp "$TEMP_DIR/$CLAUDE_MD_SRC" ~/.claude/CLAUDE.md
    echo "   CLAUDE.md"
fi

# settings.json
if [ -f "$TEMP_DIR/settings.json" ]; then
    cp "$TEMP_DIR/settings.json" ~/.claude/
    echo "   settings.json"
fi

# agents
if [ -d "$TEMP_DIR/$AGENTS_SRC" ]; then
    cp "$TEMP_DIR/$AGENTS_SRC/"*.md ~/.claude/agents/ 2>/dev/null || true
    echo "   agents/ (12)"
fi

# skills
if [ -d "$TEMP_DIR/$SKILLS_SRC" ]; then
    cp -r "$TEMP_DIR/$SKILLS_SRC/"* ~/.claude/skills/ 2>/dev/null || true
    echo "   skills/ (42, incl. docs suite)"
fi

# rules
if [ -d "$TEMP_DIR/$RULES_SRC" ]; then
    cp "$TEMP_DIR/$RULES_SRC/"*.md ~/.claude/rules/ 2>/dev/null || true
    echo "   rules/ (9, conditional loading)"
fi

# commands
if [ -d "$TEMP_DIR/$COMMANDS_SRC" ]; then
    cp "$TEMP_DIR/$COMMANDS_SRC/"*.md ~/.claude/commands/ 2>/dev/null || true
    echo "   commands/ (3)"
fi

# team-roles (TTH)
if [ -d "$TEMP_DIR/$TEAM_ROLES_SRC" ]; then
    cp "$TEMP_DIR/$TEAM_ROLES_SRC/"*.md ~/.claude/team-roles/ 2>/dev/null || true
    echo "   team-roles/ (6 CEO personas)"
fi

# hooks (language-independent)
if [ -d "$TEMP_DIR/hooks" ]; then
    cp "$TEMP_DIR/hooks/"*.sh ~/.claude/hooks/ 2>/dev/null || true
    chmod +x ~/.claude/hooks/*.sh 2>/dev/null || true
    echo "   hooks/ (20 scripts)"
fi

# scripts (language-independent)
if [ -d "$TEMP_DIR/scripts" ]; then
    cp "$TEMP_DIR/scripts/"* ~/.claude/scripts/ 2>/dev/null || true
    chmod +x ~/.claude/scripts/*.sh 2>/dev/null || true
    echo "   scripts/ (sarif-to-jsonl, validate-harness)"
fi

# templates (language-independent)
if [ -d "$TEMP_DIR/templates" ]; then
    cp "$TEMP_DIR/templates/"* ~/.claude/templates/ 2>/dev/null || true
    echo "   templates/ (3)"
fi

# semgrep rules (language-independent)
if [ -d "$TEMP_DIR/semgrep-rules" ]; then
    cp "$TEMP_DIR/semgrep-rules/"*.yaml ~/.claude/semgrep-rules/ 2>/dev/null || true
    echo "   semgrep-rules/ (2 taint rules)"
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo ""
if [ "$LANG_CHOICE" = "en" ]; then
    echo "Installation complete!"
    echo ""
    echo "Installed to: ~/.claude/"
    echo ""
    echo "Installed items:"
    echo "   - CLAUDE.md (paper-based optimized config)"
    echo "   - settings.json (permissions + Hooks guarantee + Agent Teams)"
    echo "   - agents/ (12 agents)"
    echo "   - skills/ (42 skills, incl. docs suite)"
    echo "   - rules/ (9, YAML conditional loading)"
    echo "   - commands/ (3 slash commands)"
    echo "   - team-roles/ (7 TTH CEO personas)"
    echo "   - hooks/ (20 scripts)"
    echo "   - scripts/ + templates/ + semgrep-rules/"
    echo ""
    echo "TTH Multi-Agent:"
    echo "   /tth [description]  -> M7 CEO team autonomous collaboration (Toss+Tesla+Ralph)"
    echo ""
    echo "Workflows:"
    echo "   /prd [idea]         -> PRD.md (insight-driven planning)"
    echo "   /docs [type]        -> Docs router: code|arch|api|manual|ops|ci|sync|all"
    echo "   /plan, /spec, /spec-verify, /frontend, /verify, /e2e-verify"
    echo "   /commit-push-pr, /review, /simplify, /tdd"
    echo "   /build-fix, /handoff, /compact-guide, /techdebt"
    echo ""
    echo "Plugin installation (alternative):"
    echo "   claude plugin marketplace add jh941213/my-cc-harness"
    echo "   claude plugin install my-cc-harness@my-cc-harness"
else
    echo "설치 완료!"
    echo ""
    echo "설치된 위치: ~/.claude/"
    echo ""
    echo "설치된 항목:"
    echo "   - CLAUDE.md (논문 기반 최적화 94줄)"
    echo "   - settings.json (권한 + Hooks 보장 + Agent Teams)"
    echo "   - agents/ (12개 에이전트)"
    echo "   - skills/ (42개 스킬, docs 스위트 포함)"
    echo "   - rules/ (9개, YAML 조건부 로드)"
    echo "   - commands/ (3개 슬래시 커맨드)"
    echo "   - team-roles/ (7개 TTH CEO 페르소나)"
    echo "   - hooks/ (20개 스크립트)"
    echo "   - scripts/ + templates/ + semgrep-rules/"
    echo ""
    echo "TTH 멀티 에이전트:"
    echo "   /tth [설명]      -> M7 CEO 팀이 자율 협업 (Toss+Tesla+Ralph)"
    echo ""
    echo "워크플로우:"
    echo "   /prd [아이디어]   -> PRD.md (인사이트 중심 기획)"
    echo "   /docs             -> /docs/ 자동 문서 생성"
    echo "   /plan, /spec, /spec-verify, /frontend, /verify, /e2e-verify"
    echo "   /commit-push-pr, /review, /simplify, /tdd"
    echo "   /build-fix, /handoff, /compact-guide, /techdebt"
    echo ""
    echo "플러그인 방식 설치 (권장):"
    echo "   claude plugin marketplace add jh941213/my-cc-harness"
    echo "   claude plugin install my-cc-harness@my-cc-harness"
fi
echo ""
