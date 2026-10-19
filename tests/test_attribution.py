# -*- coding: utf-8 -*-⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
# 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识
"""归属行测试:仓库内 .md/.m/.py/.tex 必须带可见的作者/仓库/许可声明行。

新增文件忘了补时本测试会红,运行 `python tools/attribution.py --apply` 即可。
"""
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

import attribution as at  # noqa: E402


class AttributionTests(unittest.TestCase):
    def test_all_files_have_attribution(self):
        missing = []
        total = 0
        for path in at.iter_files(ROOT):
            total += 1
            if not at.MARKER_RE.search(path.read_text(encoding="utf-8")):
                missing.append(path.relative_to(ROOT).as_posix())
        self.assertGreater(total, 100, "扫描到的文件数异常,检查 iter_files 跳过规则")
        self.assertEqual(missing, [],
                         f"缺归属行 {len(missing)} 个,运行 --apply 补上: {missing[:10]}")

    def test_attribution_does_not_break_python(self):
        """归属行是注释,不得破坏 .py 语法。"""
        import py_compile
        bad = []
        for path in at.iter_files(ROOT):
            if path.suffix != ".py":
                continue
            try:
                py_compile.compile(str(path), doraise=True, cfile=str(path) + ".attrc")
            except py_compile.PyCompileError as exc:
                bad.append(f"{path.relative_to(ROOT)}: {exc}")
            finally:
                tmp = Path(str(path) + ".attrc")
                if tmp.exists():
                    tmp.unlink()
        self.assertEqual(bad, [], f"归属行破坏了语法: {bad}")

    def test_attribution_not_in_third_party(self):
        rels = [p.relative_to(ROOT).as_posix() for p in at.iter_files(ROOT)]
        for rel in rels:
            self.assertFalse(rel.startswith(("tools/docx", "tools/pdf", "tools/xlsx")),
                             "第三方目录不应被写入归属行")


if __name__ == "__main__":
    unittest.main()
