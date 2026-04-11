#!/usr/bin/env python3
"""SourceCode Browse MCP Server

토스 Security Research 패턴 기반:
- ctags로 심볼 정의 사전 인덱싱
- tree-sitter로 함수 범위 구조적 파싱
- AI에게 "Go to Definition / Find References" 능력 부여

사용법:
  python3 server.py /path/to/repo
"""

import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Optional

from mcp.server.fastmcp import FastMCP

# --- 설정 ---
REPO_ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
CTAGS_INDEX: dict[str, list[dict]] = {}

mcp = FastMCP("sourcecode-browse")


# --- ctags 인덱싱 ---
def build_ctags_index(repo_root: Path) -> dict[str, list[dict]]:
    """universal-ctags로 심볼 인덱스 빌드"""
    index: dict[str, list[dict]] = {}

    with tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False) as f:
        tags_file = f.name

    try:
        subprocess.run(
            [
                "ctags",
                "--output-format=json",
                "--fields=+nKS",
                "--kinds-all=*",
                "-R",
                "-f", tags_file,
                str(repo_root),
            ],
            capture_output=True,
            text=True,
            timeout=120,
        )

        with open(tags_file) as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                    name = entry.get("name", "")
                    if name and entry.get("_type") == "tag":
                        index.setdefault(name, []).append({
                            "file": entry.get("path", ""),
                            "line": entry.get("line", 0),
                            "kind": entry.get("kind", ""),
                            "language": entry.get("language", ""),
                            "signature": entry.get("signature", ""),
                            "scope": entry.get("scope", ""),
                            "scopeKind": entry.get("scopeKind", ""),
                        })
                except json.JSONDecodeError:
                    continue
    finally:
        os.unlink(tags_file)

    return index


# --- tree-sitter 함수 범위 감지 ---
def detect_function_bounds(file_path: Path, target_line: int) -> Optional[tuple[int, int]]:
    """tree-sitter로 target_line을 포함하는 함수의 시작/끝 라인 반환"""
    suffix = file_path.suffix
    lang_map = {
        ".ts": ("tree_sitter_typescript", "typescript"),
        ".tsx": ("tree_sitter_typescript", "tsx"),
        ".js": ("tree_sitter_javascript", None),
        ".jsx": ("tree_sitter_javascript", None),
        ".py": ("tree_sitter_python", None),
    }

    if suffix not in lang_map:
        return None

    module_name, sublang = lang_map[suffix]

    try:
        import tree_sitter
        mod = __import__(module_name)

        if sublang == "typescript":
            language = tree_sitter.Language(mod.language_typescript())
        elif sublang == "tsx":
            language = tree_sitter.Language(mod.language_tsx())
        else:
            language = tree_sitter.Language(mod.language())

        parser = tree_sitter.Parser(language)
        source = file_path.read_bytes()
        tree = parser.parse(source)

        func_types = {
            "function_declaration", "method_definition", "arrow_function",
            "function_definition", "method_declaration",
            "lexical_declaration",  # const fn = () => {} 패턴
            "class_declaration", "class_definition",
            "export_statement",  # export function/class 래퍼
        }

        def find_enclosing(node, line):
            best = None
            for child in node.children:
                if child.start_point.row <= line <= child.end_point.row:
                    if child.type in func_types:
                        best = child
                    deeper = find_enclosing(child, line)
                    if deeper:
                        best = deeper
            return best

        node = find_enclosing(tree.root_node, target_line - 1)  # 0-indexed
        if node:
            return (node.start_point.row + 1, node.end_point.row + 1)
    except Exception:
        pass

    return None


def _find_file(path: str) -> Path:
    """상대/절대 경로 모두 지원"""
    p = Path(path)
    if p.is_absolute() and p.exists():
        return p
    candidate = REPO_ROOT / path
    if candidate.exists():
        return candidate
    raise FileNotFoundError(f"File not found: {path}")


# --- MCP Tools ---

@mcp.tool()
def find_references(
    symbol_or_pattern: str,
    dir: Optional[str] = None,
    max_results: int = 50,
) -> dict:
    """심볼이나 패턴의 참조를 ripgrep으로 검색"""
    search_dir = str(REPO_ROOT / dir) if dir else str(REPO_ROOT)

    try:
        result = subprocess.run(
            ["rg", "-n", "--json", "-m", str(max_results), symbol_or_pattern, search_dir],
            capture_output=True, text=True, timeout=30,
        )
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return {"references": [], "total": 0, "truncated": False}

    refs = []
    for line in result.stdout.splitlines():
        try:
            data = json.loads(line)
            if data.get("type") == "match":
                match_data = data["data"]
                file_path = match_data["path"]["text"]
                rel_path = str(Path(file_path).relative_to(REPO_ROOT))
                refs.append({
                    "file": rel_path,
                    "line": match_data["line_number"],
                    "snippet": match_data["lines"]["text"].strip(),
                })
        except (json.JSONDecodeError, KeyError):
            continue

    return {
        "references": refs[:max_results],
        "total": len(refs),
        "truncated": len(refs) >= max_results,
    }


@mcp.tool()
def read_definition(
    symbol: str,
    file: Optional[str] = None,
    include_body: bool = True,
) -> dict:
    """심볼의 정의를 ctags 인덱스에서 찾아 반환. include_body=True면 tree-sitter로 함수 전체 본문 포함."""
    entries = CTAGS_INDEX.get(symbol, [])

    if file:
        entries = [e for e in entries if file in e["file"]]

    results = []
    for e in entries[:10]:
        item = {
            "file": e["file"],
            "line": e["line"],
            "kind": e["kind"],
            "language": e["language"],
            "signature": e["signature"],
            "scope": e["scope"],
        }

        if include_body:
            try:
                p = _find_file(e["file"])
                bounds = detect_function_bounds(p, e["line"])
                if bounds:
                    lines = p.read_text(errors="ignore").splitlines()
                    item["body"] = "\n".join(lines[bounds[0] - 1:bounds[1]])
                    item["bounds"] = f"{bounds[0]}-{bounds[1]}"
            except (FileNotFoundError, Exception):
                pass

        results.append(item)

    return {"symbol": symbol, "definitions": results, "total": len(entries)}


@mcp.tool()
def read_source(
    path: str,
    line: int,
    before: int = 40,
    after: int = 40,
) -> dict:
    """지정된 라인 주변의 소스 코드를 읽어옴"""
    p = _find_file(path)
    lines = p.read_text(errors="ignore").splitlines()

    start = max(1, line - before)
    end = min(len(lines), line + after)
    text = "\n".join(f"{i}: {lines[i-1]}" for i in range(start, end + 1))

    return {
        "path": str(p.relative_to(REPO_ROOT)) if str(p).startswith(str(REPO_ROOT)) else str(p),
        "start_line": start,
        "end_line": end,
        "total_lines": len(lines),
        "content": text,
    }


@mcp.tool()
def get_project_structure(
    max_depth: int = 5,
    include_file_sizes: bool = False,
) -> dict:
    """프로젝트 디렉터리 구조 반환"""
    skip_dirs = {".git", "node_modules", "__pycache__", ".next", "dist", "build", ".venv", "venv"}
    skip_exts = {".pyc", ".pyo", ".class", ".o", ".so", ".dylib"}

    structure = []
    total_files = 0

    for root, dirs, files in os.walk(REPO_ROOT):
        dirs[:] = [d for d in dirs if d not in skip_dirs]
        rel_root = Path(root).relative_to(REPO_ROOT)
        depth = len(rel_root.parts)

        if depth >= max_depth:
            dirs.clear()
            continue

        for f in sorted(files):
            if Path(f).suffix in skip_exts:
                continue
            rel_path = str(rel_root / f) if str(rel_root) != "." else f
            entry = {"path": rel_path}
            if include_file_sizes:
                try:
                    entry["size"] = (Path(root) / f).stat().st_size
                except OSError:
                    pass
            structure.append(entry)
            total_files += 1

    return {
        "root": str(REPO_ROOT),
        "total_files": total_files,
        "max_depth": max_depth,
        "files": structure[:2000],  # 최대 2000개
        "truncated": total_files > 2000,
    }


# --- 시작 ---
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 server.py /path/to/repo", file=sys.stderr)
        print("  Indexes the repo with ctags and starts the MCP server.", file=sys.stderr)
        sys.exit(1)

    print(f"Indexing {REPO_ROOT}...", file=sys.stderr)
    CTAGS_INDEX = build_ctags_index(REPO_ROOT)
    print(f"Indexed {sum(len(v) for v in CTAGS_INDEX.values())} symbols from {len(CTAGS_INDEX)} unique names", file=sys.stderr)

    mcp.run()
