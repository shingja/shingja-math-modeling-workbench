# 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
"""Subagent 调度与门禁协议测试 (v4.0.0 重写, 2026-08-16)

断言内容与当前 SKILL.md / 角色文件实际内容对齐。
所有文件按 UTF-8 读取, 同时验证编码完整性。
"""
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def read(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8")


class SubagentProtocolTests(unittest.TestCase):
    def test_root_requires_stage_gates(self):
        text = read("SKILL.md")
        for gate in ("M1", "P1", "C1", "P2", "W1", "W2"):
            self.assertIn(gate, text)
        self.assertIn("protocols/Subagent调度.md", text)

    def test_role_entries_reference_their_gates(self):
        roles = {
            "references/roles/Linger/SKILL.md": ("M1",),
            "references/roles/Tide/SKILL.md": ("P1", "P2", "C1"),
            "references/roles/Gloom/SKILL.md": ("W1", "W2"),
        }
        for path, gates in roles.items():
            text = read(path)
            for gate in gates:
                self.assertIn(gate, text, path)

    def test_role_entries_have_new_and_optimize_modes(self):
        programming = read("references/roles/Tide/SKILL.md")
        writing = read("references/roles/Gloom/SKILL.md")
        for token in ("新建", "优化"):
            self.assertIn(token, programming)
            self.assertIn(token, writing)

    def test_midstage_gates_precede_expensive_work(self):
        programming = read("references/roles/Tide/SKILL.md")
        self.assertLess(programming.index("P1"), programming.index("提交包重跑验证"))
        writing = read("references/roles/Gloom/SKILL.md")
        self.assertLess(writing.index("W1"), writing.index("CUMCM 硬性门控"))

    def test_lessons_library_loaded_by_roles(self):
        root = read("SKILL.md")
        self.assertIn("references/lessons/", root)
        modeler = read("references/roles/Linger/SKILL.md")
        self.assertIn("外部对标协议.md", modeler)
        self.assertIn("避坑手册_Tide.md", modeler)
        programmer = read("references/roles/Tide/SKILL.md")
        self.assertIn("避坑手册_Tide.md", programmer)
        self.assertIn("joint_calibration_protocol.md", programmer)
        writer = read("references/roles/Gloom/SKILL.md")
        self.assertIn("诚实披露协议.md", writer)
        self.assertIn("多轮审计迭代协议.md", writer)
        self.assertIn("提交包规范.md", writer)

    def test_lessons_files_exist(self):
        lessons = (
            "实战复盘_机理优化.md",
            "避坑手册_Tide.md",
            "避坑手册_Gloom.md",
            "诚实披露协议.md",
            "多轮审计迭代协议.md",
            "外部对标协议.md",
            "提交包规范.md",
        )
        for name in lessons:
            self.assertTrue((ROOT / "references" / "lessons" / name).is_file(), name)

    def test_schedule_has_c1_gate_row(self):
        text = read("protocols/Subagent调度.md")
        self.assertIn("C1", text)
        self.assertIn("联合校准", text)

    def test_reviewers_are_read_only_and_evidence_based(self):
        text = read("protocols/Subagent调度.md")
        for token in ("默认只读", "输入快照", "PASS", "FAIL", "BLOCKED", "实质变化时"):
            self.assertIn(token, text)

    def test_all_md_files_are_valid_utf8(self):
        bad = []
        for path in ROOT.rglob("*.md"):
            if ".git" in path.parts or "__pycache__" in path.parts:
                continue
            try:
                path.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                bad.append(str(path))
        self.assertEqual(bad, [], f"非 UTF-8 文件: {bad}")

    def test_electronic_paper_structure_in_writing_gates(self):
        text = read("references/roles/Gloom/SKILL.md")
        self.assertIn("摘要页", text)
        self.assertIn("电子版", text)


if __name__ == "__main__":
    unittest.main()
# 
