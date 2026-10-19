#!/usr/bin/env python3
# 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
"""内容哈希清单:逐文件 SHA-256,用于证明版本与检测篡改。

`provenance_manifest.json` 记录每个被跟踪文件的 SHA-256。它的用途：

- **证明版本先后**：搬运者若改动内容再声称"我才是原创"，哈希对不上；
- **检测篡改**：任何人改一个字符，`--verify` 立即报出；
- **发布留证**：每次发版更新一次，配合签名提交形成证据链。

用法：
    python tools/manifest.py --update     # 重新生成清单（改完内容后必须跑）
    python tools/manifest.py --verify     # 校验当前内容与清单一致
"""
from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "provenance_manifest.json"
SKIP_PREFIXES = ("docs/internal/", "tools/docx/", "tools/pdf/", "tools/xlsx/")
SELF = "provenance_manifest.json"
# 非二进制文件按 LF 归一化后计算哈希，保证 Windows(CRLF) 与 CI(LF) 结果一致。
BINARY_SUFFIXES = {".png", ".jpg", ".jpeg", ".gif", ".pdf", ".docx", ".xlsx",
                   ".mat", ".pt", ".zip", ".gz", ".whl"}


def tracked_files() -> list[str]:
    """git 跟踪的文件 + 未跟踪但未被忽略的新文件。"""
    result = subprocess.run(
        ["git", "-c", "core.quotepath=false",
         "ls-files", "--cached", "--others", "--exclude-standard"],
        cwd=ROOT, capture_output=True, text=True, encoding="utf-8", errors="replace",
    )
    if result.returncode != 0 or result.stdout is None:
        print("git ls-files 失败，请确认在 git 仓库内运行", file=sys.stderr)
        return []
    files = []
    for line in result.stdout.split("\n"):
        rel = line.strip()
        if not rel or rel == SELF:
            continue
        if any(rel.startswith(prefix) for prefix in SKIP_PREFIXES):
            continue
        if (ROOT / rel).is_file():
            files.append(rel)
    return sorted(files)


def sha256(path: Path) -> str:
    data = path.read_bytes()
    if path.suffix.lower() not in BINARY_SUFFIXES:
        data = data.replace(bytes([13, 10]), bytes([10]))
    return hashlib.sha256(data).hexdigest()


def build() -> dict:
    version = (ROOT / "VERSION").read_text(encoding="utf-8").strip()
    return {
        "schema": 1,
        "project": "Math Modeling Workbench (shingja/shingja-math-modeling-workbench)",
        "author": "shingja",
        "license": "dual (non-commercial free; commercial by written permission) — see LICENSE",
        "version": version,
        "hash": "sha256",
        "files": {rel: sha256(ROOT / rel) for rel in tracked_files()},
    }


def do_update() -> int:
    data = build()
    MANIFEST.write_text(
        json.dumps(data, ensure_ascii=False, indent=1, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    print(f"已写入 {SELF}：{len(data['files'])} 个文件，版本 {data['version']}")
    return 0


def do_verify() -> int:
    if not MANIFEST.exists():
        print(f"缺少 {SELF}；请先运行 python tools/manifest.py --update", file=sys.stderr)
        return 1
    recorded = json.loads(MANIFEST.read_text(encoding="utf-8"))["files"]
    current = build()["files"]

    added = sorted(set(current) - set(recorded))
    removed = sorted(set(recorded) - set(current))
    changed = sorted(rel for rel in set(recorded) & set(current) if recorded[rel] != current[rel])

    print(f"清单 {len(recorded)} 个文件，当前 {len(current)} 个文件")
    problems = 0
    for label, items in (("新增未登记", added), ("清单有但已删除", removed), ("内容被改动", changed)):
        if items:
            problems += len(items)
            print(f"\n{label}（{len(items)}）:")
            for rel in items[:25]:
                print("  " + rel)
            if len(items) > 25:
                print(f"  ... 另有 {len(items) - 25} 个")

    if problems:
        print("\n校验未通过。改动内容后请运行：python tools/manifest.py --update")
        return 1
    print("全部文件与清单一致，内容未被篡改")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="内容哈希清单")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--update", action="store_true", help="重新生成清单")
    group.add_argument("--verify", action="store_true", help="校验内容与清单一致")
    args = parser.parse_args()
    return do_update() if args.update else do_verify()


if __name__ == "__main__":
    sys.exit(main())
