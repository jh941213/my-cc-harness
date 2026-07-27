#!/bin/bash
# check-docs-freshness.sh — docs drift check based on docs/docs.yaml
# stale when: (1) latest commit under covers > last_reviewed, (2) review older than review_max_age_days
# exit code: 0 = all fresh, 1 = stale docs exist

set -uo pipefail

MANIFEST="${1:-docs/docs.yaml}"
[ -f "$MANIFEST" ] || { echo "No manifest: $MANIFEST — generate one with the docs-ci skill"; exit 0; }

python3 - "$MANIFEST" <<'PYEOF'
import re, subprocess, sys, datetime

manifest_path = sys.argv[1]
text = open(manifest_path, encoding="utf-8").read()

# Minimal dependency-free YAML parsing (supports the docs.yaml convention shape only)
max_age = 90
m = re.search(r"^review_max_age_days:\s*(\d+)", text, re.M)
if m: max_age = int(m.group(1))

entries = []
current = None
for line in text.splitlines():
    if re.match(r"^\s*-\s+path:", line):
        if current: entries.append(current)
        current = {"path": line.split("path:", 1)[1].strip(), "covers": [], "last_reviewed": None}
    elif current is not None:
        cm = re.match(r"^\s*covers:\s*\[(.*)\]", line)
        if cm:
            current["covers"] = [c.strip().strip('"').strip("'") for c in cm.group(1).split(",") if c.strip()]
        rm = re.match(r"^\s*last_reviewed:\s*([\d-]+)", line)
        if rm:
            current["last_reviewed"] = rm.group(1)
if current: entries.append(current)

def latest_commit_ts(paths):
    ts = 0
    for p in paths:
        if p.startswith("!"): continue
        try:
            out = subprocess.run(
                ["git", "log", "-1", "--format=%ct", "--", p],
                capture_output=True, text=True, timeout=30,
            ).stdout.strip()
            if out: ts = max(ts, int(out))
        except Exception:
            pass
    return ts

today = datetime.date.today()
stale = []
for e in entries:
    if not e["last_reviewed"]:
        stale.append((e["path"], "missing last_reviewed"))
        continue
    reviewed = datetime.date.fromisoformat(e["last_reviewed"])
    age = (today - reviewed).days
    if age > max_age:
        stale.append((e["path"], f"{age} days since review (threshold {max_age})"))
        continue
    code_ts = latest_commit_ts(e["covers"])
    if code_ts:
        code_date = datetime.date.fromtimestamp(code_ts)
        if code_date > reviewed:
            stale.append((e["path"], f"latest code change ({code_date}) > doc review date ({reviewed})"))

if stale:
    print("🟡 stale docs:")
    for path, reason in stale:
        print(f"  - {path}: {reason}")
    sys.exit(1)
print(f"✅ all {len(entries)} docs fresh")
sys.exit(0)
PYEOF
