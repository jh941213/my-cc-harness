#!/usr/bin/env python3
"""SARIF → 경량 JSONL 변환기

토스 Security Research 패턴 기반:
- SARIF에서 file_path, line_num, code_snippet만 추출
- 연속 라인 병합으로 토큰 절약
- MB 단위 SARIF → KB 단위 JSONL

사용법:
  python3 sarif-to-jsonl.py semgrep-output.sarif > candidates.jsonl
"""

import json
import sys
from collections import defaultdict


def parse_sarif(sarif_path: str) -> list[dict]:
    with open(sarif_path) as f:
        data = json.load(f)

    entries = []
    for run in data.get("runs", []):
        for result in run.get("results", []):
            for loc in result.get("locations", []):
                phys = loc.get("physicalLocation", {})
                artifact = phys.get("artifactLocation", {})
                region = phys.get("region", {})
                snippet = region.get("snippet", {})

                entries.append({
                    "file_path": artifact.get("uri", ""),
                    "line_num": region.get("startLine", 0),
                    "end_line": region.get("endLine", region.get("startLine", 0)),
                    "code_snippet": snippet.get("text", "").strip(),
                })

    return entries


def merge_consecutive(entries: list[dict]) -> list[dict]:
    """같은 파일의 연속 라인을 병합"""
    by_file = defaultdict(list)
    for e in entries:
        by_file[e["file_path"]].append(e)

    merged = []
    idx = 1

    for file_path, file_entries in sorted(by_file.items()):
        file_entries.sort(key=lambda x: x["line_num"])

        group = file_entries[0].copy()
        for e in file_entries[1:]:
            if e["line_num"] <= group["end_line"] + 3:  # 3줄 이내면 병합
                group["end_line"] = max(group["end_line"], e["end_line"])
                group["code_snippet"] += "\n" + e["code_snippet"]
            else:
                line = f"{group['line_num']}-{group['end_line']}" if group["line_num"] != group["end_line"] else str(group["line_num"])
                merged.append({
                    "id": idx,
                    "file_path": group["file_path"],
                    "line_num": line,
                    "code_snippet": group["code_snippet"],
                })
                idx += 1
                group = e.copy()

        line = f"{group['line_num']}-{group['end_line']}" if group["line_num"] != group["end_line"] else str(group["line_num"])
        merged.append({
            "id": idx,
            "file_path": group["file_path"],
            "line_num": line,
            "code_snippet": group["code_snippet"],
        })
        idx += 1

    return merged


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 sarif-to-jsonl.py <sarif-file>", file=sys.stderr)
        sys.exit(1)

    entries = parse_sarif(sys.argv[1])
    if not entries:
        print("[]")
        return

    merged = merge_consecutive(entries)
    print(json.dumps(merged, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
