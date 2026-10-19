#!/usr/bin/env python3
# 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
"""归属行:给每个源文件插入一条可见的作者/仓库/许可声明。

可见归属行用于**日常可见的署名**（渲染/阅读时就能看到归属）。

插入位置（保证不破坏语法/渲染）：
- `.md`  有 YAML frontmatter 时插在 frontmatter 之后，否则插在首行标题之后
- `.py`  插在 shebang 与 coding 声明之后
- `.m`   插在文件首行
- `.tex` 插在文件首行

用法：
    python tools/attribution.py --apply     # 给缺失的文件补归属行（幂等）
    python tools/attribution.py --check     # 校验，缺失则退出码 1
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

AUTHOR = "shingja"
REPO_URL = "github.com/shingja/shingja-math-modeling-workbench"
ZH = f"作者 {AUTHOR} · {REPO_URL} · 双许可见 LICENSE · 保留版权标识"
EN = f"Author {AUTHOR} · {REPO_URL} · dual-licensed, see LICENSE · retains copyright identifiers"

EXTENSIONS = {".md", ".py", ".m", ".tex", ".svg", ".yml", ".yaml", ".cff"}
SKIP_DIRS = {".git", ".backups", "__pycache__"}
SKIP_PREFIXES = ("tools/docx/", "tools/pdf/", "tools/xlsx/", "docs/internal/", "docs/history/audit/")

MARKER_RE = re.compile(r"作者 shingja · github\.com/shingja/shingja-math-modeling-workbench")
CODING_RE = re.compile(r"^#.*coding[:=]")


def comment_style(suffix: str) -> tuple[str, str]:
    if suffix in {".md", ".svg"}:
        return "<!-- ", " -->"
    if suffix in {".yml", ".yaml", ".cff"}:
        return "# ", ""
    if suffix in {".py", ".m", ".tex"}:
        return ("# ", "") if suffix == ".py" else ("% ", "")
    raise ValueError(suffix)


def build_line(suffix: str) -> str:
    prefix, suffix_close = comment_style(suffix)
    return f"{prefix}{ZH}{suffix_close}"


def insertion_index(lines: list[str], suffix: str) -> int:
    if suffix == ".svg":
        # XML 声明必须是第一行
        if lines and lines[0].lstrip().startswith("<?xml"):
            return 1
        return 0
    if suffix == ".md":
        if lines and lines[0].strip() == "---":
            for i in range(1, len(lines)):
                if lines[i].strip() == "---":
                    return i + 1
        return 1 if lines else 0
    if suffix == ".py":
        index = 0
        for i, line in enumerate(lines[:3]):
            if line.startswith("#!") or CODING_RE.match(line):
                index = i + 1
        return index
    return 0


def iter_files(root: Path = ROOT):
    for path in sorted(root.rglob("*")):
        if not path.is_file() or path.suffix.lower() not in EXTENSIONS:
            continue
        rel = path.relative_to(root).as_posix()
        if any(part in SKIP_DIRS for part in path.parts):
            continue
        if any(rel.startswith(prefix) for prefix in SKIP_PREFIXES):
            continue
        yield path


def apply_file(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    if MARKER_RE.search(text):
        return False
    lines = text.split("\n")
    index = insertion_index(lines, path.suffix.lower())
    line = build_line(path.suffix.lower())
    insert = [line, ""] if path.suffix.lower() in {".md", ".svg"} else [line]
    lines[index:index] = insert
    path.write_text("\n".join(lines), encoding="utf-8")
    return True


def do_apply() -> int:
    changed = 0
    for path in iter_files():
        if apply_file(path):
            changed += 1
            print("补归属行  " + path.relative_to(ROOT).as_posix())
    print(f"\n共补 {changed} 个文件")
    return 0


def do_check() -> int:
    missing = [p.relative_to(ROOT).as_posix() for p in iter_files()
               if not MARKER_RE.search(p.read_text(encoding="utf-8"))]
    total = len(list(iter_files()))
    print(f"已带归属行 {total - len(missing)}/{total}")
    if missing:
        print("\n缺失(运行 --apply 补上):")
        for rel in missing[:40]:
            print("  " + rel)
        if len(missing) > 40:
            print(f"  ... 另有 {len(missing) - 40} 个")
        return 1
    print("全部文件均带归属行")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="可见归属行工具")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--apply", action="store_true")
    group.add_argument("--check", action="store_true")
    args = parser.parse_args()
    return do_apply() if args.apply else do_check()


if __name__ == "__main__":
    sys.exit(main())
