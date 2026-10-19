#!/usr/bin/env python3
# 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
"""从官方仓库获取 docx / pdf / xlsx 工具到本地 tools/。

本仓库**不分发**第三方代码。这三个工具来自 Anthropic 官方 skills 仓库
(https://github.com/anthropics/skills)，由使用者按需自行获取；获取后在本地
按原权利人的许可条款使用，本项目不为其提供任何担保。

用法：
    python tools/fetch_official_tools.py              # 获取缺失的工具
    python tools/fetch_official_tools.py --force      # 覆盖已有目录
    python tools/fetch_official_tools.py --check      # 只检查是否就绪
"""
from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO = "https://github.com/anthropics/skills.git"
TOOLS = ("docx", "pdf", "xlsx")
ROOT = Path(__file__).resolve().parents[1]


def missing() -> list[str]:
    return [name for name in TOOLS if not (ROOT / "tools" / name / "SKILL.md").exists()]


def clone_candidates(ref: str, mirror: str | None) -> list[str]:
    """按顺序给出可尝试的克隆地址。mirror 是形如 https://ghfast.top 的前缀代理。"""
    base = "https://github.com/anthropics/skills.git"
    urls = []
    if mirror:
        urls.append(mirror.rstrip("/") + "/" + base)
    urls.append(base)
    return urls


def fetch(force: bool, ref: str = "main", mirror: str | None = None) -> int:
    need = TOOLS if force else tuple(missing())
    if not need:
        print("官方工具已就绪：", ", ".join(f"tools/{n}" for n in TOOLS))
        return 0
    print("将获取：", ", ".join(need))
    with tempfile.TemporaryDirectory(prefix="official_skills_") as tmp:
        target = Path(tmp) / "skills"
        ok = False
        for url in clone_candidates(ref, mirror):
            cmd = ["git", "clone", "--depth", "1", "--branch", ref, url, str(target)]
            print("执行:", " ".join(cmd))
            if subprocess.run(cmd, text=True).returncode == 0:
                ok = True
                break
            print("  ↑ 失败，尝试下一个地址")
            if target.exists():
                shutil.rmtree(target, ignore_errors=True)
        if not ok:
            print("\n克隆失败（国内访问 GitHub 不稳时的常见情况）。可选做法：")
            print("  1) 用镜像前缀重试：")
            print("     python tools/fetch_official_tools.py --mirror https://ghfast.top")
            print("     或设环境变量 GITHUB_MIRROR=https://ghfast.top")
            print("  2) 浏览器打开 https://github.com/anthropics/skills/tree/main/skills")
            print(f"     下载 skills/<name> 后复制到 {ROOT / 'tools'}")
            return 1
        for name in need:
            source = target / "skills" / name
            if not source.is_dir():
                print(f"官方仓库中未找到 skills/{name}，跳过")
                continue
            dest = ROOT / "tools" / name
            if dest.exists():
                shutil.rmtree(dest)
            shutil.copytree(source, dest)
            license_note = dest / "LICENSE.txt"
            print(f"已安装 tools/{name}" + ("（含官方许可文件）" if license_note.exists() else ""))
    print("\n完成。注意：这些工具是第三方内容，遵循其自带许可；"
          "本仓库的 LICENSE 不适用于它们，也不随本仓库再分发。")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="获取官方 docx/pdf/xlsx 工具")
    parser.add_argument("--force", action="store_true", help="覆盖已存在的目录")
    parser.add_argument("--check", action="store_true", help="只检查")
    parser.add_argument("--ref", default="main", help="官方仓库分支或 tag（默认 main）")
    parser.add_argument("--mirror", default=os.environ.get("GITHUB_MIRROR"),
                        help="镜像代理前缀，如 https://ghfast.top（也可用环境变量 GITHUB_MIRROR）")
    args = parser.parse_args()

    if args.check:
        gaps = missing()
        if gaps:
            print("缺失：", ", ".join(f"tools/{n}" for n in gaps))
            return 1
        print("官方工具已就绪：", ", ".join(f"tools/{n}" for n in TOOLS))
        return 0
    return fetch(force=args.force, ref=args.ref, mirror=args.mirror)


if __name__ == "__main__":
    sys.exit(main())
# 
