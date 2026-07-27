#!/bin/bash
# validate-harness.sh — 하네스 구조 무결성 검증 (CI 하드 게이트)
#
# 검증 항목:
#   1. skills/*/SKILL.md, agents/*.md frontmatter 유효성 (name/description 필수)
#   2. JSON 파일 파싱 (settings.json, plugin.json, marketplace.json)
#   3. hooks/*.sh 문법 (bash -n) + 실행 권한
#   4. settings.json이 참조하는 hook 파일 존재 여부
#   5. CLAUDE.md Knowledge Map 참조 경로 존재 여부
#   6. 한/영 컴포넌트 패리티 (개수 불일치 시 경고)
#   7. plugin.json 컴포넌트 경로 존재 여부
#
# 종료 코드: 0 = 통과(경고 허용), 1 = 오류 존재
# 사용법: bash scripts/validate-harness.sh [--strict]  (--strict: 경고도 실패 처리)

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

STRICT=false
[ "${1:-}" = "--strict" ] && STRICT=true

ERRORS=0
WARNINGS=0

err()  { echo "❌ ERROR: $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo "🟡 WARN:  $1"; WARNINGS=$((WARNINGS + 1)); }
ok()   { echo "✅ $1"; }

# ---------- 1. Frontmatter 검증 ----------
check_frontmatter() {
  local file="$1" require_name="$2"
  VH_FILE="$file" VH_REQ_NAME="$require_name" python3 - <<'PYEOF'
import os, re, sys

path = os.environ["VH_FILE"]
require_name = os.environ["VH_REQ_NAME"] == "yes"
text = open(path, encoding="utf-8").read()

if not text.startswith("---\n"):
    print(f"frontmatter 시작(---) 없음")
    sys.exit(1)
end = text.find("\n---", 4)
if end == -1:
    print(f"frontmatter 종료(---) 없음")
    sys.exit(1)
fm = text[4:end]

def get_field(name):
    m = re.search(rf"^{name}:\s*(.*)$", fm, re.M)
    return m.group(1).strip().strip('"').strip("'") if m else None

problems = []
if require_name and not get_field("name"):
    problems.append("name 필드 누락")
desc = get_field("description")
if not desc:
    problems.append("description 필드 누락")
elif len(desc) > 1024:
    problems.append(f"description {len(desc)}자 (1024자 초과)")
if "\t" in fm:
    problems.append("frontmatter에 탭 문자 포함")

if problems:
    print("; ".join(problems))
    sys.exit(1)
sys.exit(0)
PYEOF
}

echo "── [1/7] SKILL.md / agents frontmatter ──"
FM_FAIL=0
for dir in skills skills_en; do
  [ -d "$dir" ] || continue
  while IFS= read -r f; do
    if ! MSG=$(check_frontmatter "$f" "yes"); then
      err "$f: $MSG"; FM_FAIL=1
    fi
  done < <(find "$dir" -name "SKILL.md" | sort)
done
for dir in agents agents_en; do
  [ -d "$dir" ] || continue
  while IFS= read -r f; do
    if ! MSG=$(check_frontmatter "$f" "yes"); then
      err "$f: $MSG"; FM_FAIL=1
    fi
  done < <(find "$dir" -maxdepth 1 -name "*.md" | sort)
done
[ "$FM_FAIL" = "0" ] && ok "frontmatter 전체 유효"

# ---------- 2. JSON 파싱 ----------
echo "── [2/7] JSON 유효성 ──"
JSON_FAIL=0
for f in settings.json settings.local.example.json .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  [ -f "$f" ] || continue
  if ! python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$f" 2>/dev/null; then
    err "$f: JSON 파싱 실패"; JSON_FAIL=1
  fi
done
[ "$JSON_FAIL" = "0" ] && ok "JSON 전체 유효"

# ---------- 3. hooks 문법 + 실행 권한 ----------
echo "── [3/7] hooks 문법/권한 ──"
HOOK_FAIL=0
for f in hooks/*.sh; do
  [ -f "$f" ] || continue
  if ! bash -n "$f" 2>/dev/null; then
    err "$f: bash 문법 오류"; HOOK_FAIL=1
  fi
  if [ ! -x "$f" ]; then
    warn "$f: 실행 권한 없음 (install.sh가 chmod +x 하지만 레포에서도 권장)"
  fi
done
[ "$HOOK_FAIL" = "0" ] && ok "hooks 문법 전체 통과"

# ---------- 4. settings.json → hook 파일 참조 ----------
echo "── [4/7] settings.json hook 참조 ──"
REF_FAIL=0
while IFS= read -r hook_path; do
  base=$(basename "$hook_path")
  if [ ! -f "hooks/$base" ]; then
    err "settings.json이 참조하는 hooks/$base 가 레포에 없음"; REF_FAIL=1
  fi
done < <(python3 - <<'PYEOF'
import json, re
s = json.load(open("settings.json"))
seen = set()
def walk(node):
    if isinstance(node, dict):
        cmd = node.get("command", "")
        if isinstance(cmd, str):
            for m in re.finditer(r"~/.claude/hooks/([\w.-]+\.sh)", cmd):
                seen.add(m.group(1))
        for v in node.values(): walk(v)
    elif isinstance(node, list):
        for v in node: walk(v)
walk(s.get("hooks", {}))
print("\n".join(sorted(seen)))
PYEOF
)
[ "$REF_FAIL" = "0" ] && ok "hook 참조 전체 유효"

# ---------- 5. CLAUDE.md 참조 경로 ----------
echo "── [5/7] CLAUDE.md 참조 경로 ──"
PATH_FAIL=0
for ref in rules templates semgrep-rules scripts agents skills team-roles; do
  if grep -q "~/.claude/${ref}/" CLAUDE.md 2>/dev/null && [ ! -d "$ref" ]; then
    err "CLAUDE.md가 ~/.claude/${ref}/ 참조하지만 레포에 ${ref}/ 없음"; PATH_FAIL=1
  fi
done
[ "$PATH_FAIL" = "0" ] && ok "CLAUDE.md 참조 경로 전체 유효"

# ---------- 6. 한/영 패리티 ----------
echo "── [6/7] 한/영 컴포넌트 패리티 ──"
parity() {
  local ko="$1" en="$2" pattern="$3"
  [ -d "$ko" ] && [ -d "$en" ] || return 0
  local ko_n en_n
  ko_n=$(find "$ko" -name "$pattern" | wc -l | tr -d ' ')
  en_n=$(find "$en" -name "$pattern" | wc -l | tr -d ' ')
  if [ "$ko_n" != "$en_n" ]; then
    warn "$ko($ko_n) vs $en($en_n) 개수 불일치"
  fi
}
parity skills skills_en "SKILL.md"
parity agents agents_en "*.md"
parity commands commands_en "*.md"
parity rules rules_en "*.md"
parity team-roles team-roles_en "*.md"
ok "패리티 검사 완료"

# ---------- 7. plugin.json 컴포넌트 경로 ----------
echo "── [7/7] plugin.json 컴포넌트 경로 ──"
PLUGIN_FAIL=0
while IFS= read -r comp_path; do
  [ -z "$comp_path" ] && continue
  clean="${comp_path#./}"
  if [ ! -e "$clean" ]; then
    err "plugin.json이 참조하는 경로 없음: $comp_path"; PLUGIN_FAIL=1
  fi
done < <(python3 - <<'PYEOF'
import json
p = json.load(open(".claude-plugin/plugin.json"))
for key in ("skills", "commands", "agents", "hooks", "mcpServers"):
    v = p.get(key)
    if isinstance(v, str):
        print(v)
    elif isinstance(v, list):
        for item in v:
            if isinstance(item, str): print(item)
PYEOF
)
[ "$PLUGIN_FAIL" = "0" ] && ok "plugin.json 경로 전체 유효"

# ---------- 결과 ----------
echo ""
echo "════════════════════════════════"
echo "오류 ${ERRORS}건 / 경고 ${WARNINGS}건"
if [ "$ERRORS" -gt 0 ]; then
  echo "❌ 검증 실패"
  exit 1
fi
if [ "$STRICT" = "true" ] && [ "$WARNINGS" -gt 0 ]; then
  echo "❌ strict 모드: 경고를 실패로 처리"
  exit 1
fi
echo "✅ 하네스 구조 검증 통과"
exit 0
