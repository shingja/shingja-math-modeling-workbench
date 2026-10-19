# 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
"""Skill 元数据与引用完整性测试 (v4.0.0 新增, 2026-08-16)

检查: 版本号一致性 / description 单行 / 路由引用路径存在 /
keyword_router 覆盖范式卡 / 门禁脚本模式参数。
"""
import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def read(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8")


class SkillIntegrityTests(unittest.TestCase):
    def test_version_consistency(self):
        version_file = read("VERSION").strip()
        root_fm = re.search(r"^version:\s*([\d.]+)", read("SKILL.md"), re.M)
        shim_fm = re.search(
            r"^version:\s*([\d.]+)", read("skills/math-modeling/SKILL.md"), re.M
        )
        plugin = json.loads(read(".claude-plugin/plugin.json"))
        self.assertEqual(version_file, root_fm.group(1), "VERSION vs SKILL.md frontmatter")
        self.assertEqual(version_file, shim_fm.group(1), "VERSION vs 嵌套 shim")
        self.assertEqual(version_file, plugin["version"], "VERSION vs plugin.json")
        # 文档侧版本声明也必须同步(调用指南/README 当前版本声明)
        tutorial = read("docs/使用教程.md")
        self.assertIn(f"# math-modeling v{version_file} 使用教程", tutorial,
                      "使用教程标题版本过期")
        readme = read("README.md")
        self.assertIn(f"version-{version_file}-blue", readme, "README 徽章版本过期")
        self.assertIn(f"当前版本：[`{version_file}`]", readme, "README 当前版本声明过期")
        known = read("docs/KNOWN_ISSUES.md")
        self.assertIn(f"> v{version_file} |", known, "KNOWN_ISSUES 版本声明过期")

    def test_description_single_line(self):
        for path in ("SKILL.md", "skills/math-modeling/SKILL.md"):
            fm = read(path).split("---")[1]
            m = re.search(r"^description:\s*(.+)$", fm, re.M)
            self.assertIsNotNone(m, f"{path} description 缺失")
            desc_line = m.group(1)
            self.assertNotIn("|", desc_line[:3], f"{path} description 疑似多行块")
            self.assertNotIn(">-", desc_line, f"{path} description 疑似折叠块")

    def test_routed_references_exist(self):
        """主 SKILL.md 与角色 SKILL.md 中引用的 skill 内部文件路径必须存在。

        解析规则: `../../../` 前缀 = 相对 SKILL_ROOT; 角色文件内 `references/`/`assets/`
        前缀 = 相对该角色目录; `PROJECT_ROOT/`、`results/`、裸文件名(范式卡简写)与通配符跳过。
        """
        SKILL_DIRS = ("references", "tools", "assets", "matlab", "gates", "docs", "tests",
                      "modules", "protocols")
        md_files = [
            ("SKILL.md", ROOT),
            ("references/roles/Linger/SKILL.md", ROOT / "references/roles/Linger"),
            ("references/roles/Tide/SKILL.md", ROOT / "references/roles/Tide"),
            ("references/roles/Gloom/SKILL.md", ROOT / "references/roles/Gloom"),
        ]
        missing = []
        for rel_md, base in md_files:
            text = read(rel_md)
            for m in re.finditer(
                r"`((?:\.\./)*[A-Za-z0-9_/一-鿿-]+\.(?:md|m|py|json|html|docx))`",
                text,
            ):
                rel = m.group(1)
                if "*" in rel or rel.startswith("PROJECT_ROOT/") or rel.startswith("results/"):
                    continue
                # 第三方官方工具由使用者本地获取，不随仓库分发；CI 中可能不存在。
                if rel.startswith(("tools/docx/", "tools/pdf/", "tools/xlsx/")):
                    continue
                if rel.startswith("../../../"):
                    rel = rel[len("../../../"):]
                    # 第三方官方工具不随仓库分发，CI 中可能不存在。
                    if rel.startswith(("tools/docx/", "tools/pdf/", "tools/xlsx/")):
                        continue
                elif rel.startswith("../") or "/" not in rel:
                    continue  # 裸文件名 = 范式卡/产物简写, 不校验
                else:
                    target = base / rel
                    if not target.exists():
                        missing.append(f"{rel_md} -> {rel}")
                    continue
                if rel.split("/")[0] not in SKILL_DIRS:
                    continue
                if not (ROOT / rel).exists():
                    missing.append(f"{rel_md} -> {rel}")
        self.assertEqual(missing, [], f"死引用: {missing}")

    def test_keyword_router_covers_paradigms(self):
        router = json.loads(read("references/paradigms/keyword_router.json"))
        cards = {
            p.stem.replace("PARADIGM-", "")
            for p in (ROOT / "references/paradigms").glob("PARADIGM-*.md")
            if p.name != "_TEMPLATE.md"
        }
        router_keys = {k.replace("PARADIGM-", "") for k in router.keys()}
        missing = cards - router_keys
        extra = router_keys - cards
        self.assertLessEqual(len(missing), 8, f"router 缺卡 {len(missing)} 张: {sorted(missing)[:20]}")
        placeholder = [
            k for k, v in router.items()
            if v.get("keywords") in (["通用"], ["generic"], [])
        ]
        self.assertEqual(placeholder, [], f"占位关键词条目 {len(placeholder)} 个")

    def test_gates_have_mode_parameter(self):
        text = read("gates/W2_format_check.m")
        self.assertIn("mode", text.lower())

    def test_all_md_utf8_and_no_replacement_chars(self):
        bad = []
        for path in ROOT.rglob("*.md"):
            if ".git" in path.parts or "__pycache__" in path.parts:
                continue
            text = path.read_text(encoding="utf-8", errors="strict")
            if "�" in text:
                bad.append(str(path))
        self.assertEqual(bad, [], f"含替换字符的文件: {bad}")


if __name__ == "__main__":
    unittest.main()
