# -*- coding: utf-8 -*-⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
# 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识
"""隐私与合规回归测试。

两层检查：
1. **结构性模式**（永远执行）：个人机器路径、私人邮箱、手机号、第三方代码目录。
2. **禁词表**（可选）：若本地存在 `docs/internal/forbidden_terms.txt`（该文件不入库），
   逐行作为禁词全文扫描；公开仓库上该文件不存在，此层自动跳过。
"""
from __future__ import annotations

import re
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCAN_EXTENSIONS = {".md", ".py", ".m", ".json", ".txt", ".yml", ".yaml", ".tex", ".csv", ".svg", ".html"}
SKIP_DIRS = {".git", ".backups", "__pycache__", "node_modules", "venv", ".venv"}
SKIP_PREFIXES = ("tools/docx/", "tools/pdf/", "tools/xlsx/", "docs/internal/")
# 机器生成的哈希清单（内含大段十六进制，不作为作者文本扫描）
SKIP_FILES = {"provenance_manifest.json"}
FORBIDDEN_TERMS_FILE = ROOT / "docs" / "internal" / "forbidden_terms.txt"

STRUCTURAL_PATTERNS = [
    (re.compile(r"C:\\Users\\(?!<)[A-Za-z0-9]"), "真实 Windows 用户目录"),
    (re.compile(r"D:\\桌面"), "本机桌面路径"),
    (re.compile(r"D:\\MATH"), "旧机器项目盘路径"),
    (re.compile(r"[A-Za-z0-9._%+-]+@(126|163|qq|gmail|foxmail|outlook)\.com", re.I), "私人邮箱"),
    (re.compile(r"(?<![0-9a-fA-F])1[3-9]\d{9}(?![0-9a-fA-F])"), "手机号样式"),
]
# 作者主动公开的联系邮箱（与个人主页一致），不属于隐私泄露。
PUBLIC_CONTACT_EMAILS = {"gy79790920@126.com"}


def scanned_files() -> list[Path]:
    result = []
    for path in sorted(ROOT.rglob("*")):
        if not path.is_file() or path.suffix.lower() not in SCAN_EXTENSIONS:
            continue
        rel = path.relative_to(ROOT).as_posix()
        if any(part in SKIP_DIRS for part in path.parts):
            continue
        if rel in SKIP_FILES:
            continue
        if any(rel.startswith(prefix) for prefix in SKIP_PREFIXES):
            continue
        result.append(path)
    return result


class PrivacyTests(unittest.TestCase):
    def test_no_structural_patterns(self):
        hits = []
        for path in scanned_files():
            for lineno, line in enumerate(path.read_text(encoding="utf-8", errors="ignore").split("\n"), 1):
                for pattern, label in STRUCTURAL_PATTERNS:
                    match = pattern.search(line)
                    if not match:
                        continue
                    if label == "私人邮箱" and match.group(0).lower() in PUBLIC_CONTACT_EMAILS:
                        continue
                    hits.append(f"{path.relative_to(ROOT)}:{lineno} [{label}] {line.strip()[:60]}")
        self.assertEqual(hits, [], f"命中 {len(hits)} 处隐私模式:\n" + "\n".join(hits[:15]))

    def test_no_forbidden_terms(self):
        if not FORBIDDEN_TERMS_FILE.exists():
            self.skipTest("未提供 docs/internal/forbidden_terms.txt（公开仓库正常跳过）")
        terms = [
            line.strip()
            for line in FORBIDDEN_TERMS_FILE.read_text(encoding="utf-8").split("\n")
            if line.strip() and not line.strip().startswith("#")
        ]
        hits = []
        for path in scanned_files():
            text = path.read_text(encoding="utf-8", errors="ignore")
            for term in terms:
                if term in text:
                    hits.append(f"{path.relative_to(ROOT)} :: {term}")
        self.assertEqual(hits, [], f"禁词命中 {len(hits)} 处: {hits[:10]}")

    def test_internal_dir_not_tracked(self):
        """内部资料目录绝不能被 git 跟踪。"""
        result = subprocess.run(
            ["git", "ls-files", "docs/internal"],
            cwd=ROOT, capture_output=True, text=True, encoding="utf-8", errors="replace",
        )
        tracked = [line for line in result.stdout.split("\n") if line.strip()]
        self.assertEqual(tracked, [], f"docs/internal 被跟踪: {tracked[:5]}")

    def test_third_party_dirs_not_tracked(self):
        """Anthropic 官方工具不得随仓库分发。"""
        result = subprocess.run(
            ["git", "ls-files", "tools/docx", "tools/pdf", "tools/xlsx"],
            cwd=ROOT, capture_output=True, text=True, encoding="utf-8", errors="replace",
        )
        tracked = [line for line in result.stdout.split("\n") if line.strip()]
        self.assertEqual(tracked, [], f"第三方代码被跟踪: {tracked[:5]}")


if __name__ == "__main__":
    unittest.main()
