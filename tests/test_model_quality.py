# 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
"""model_quality_score.py 工具测试 (v4.2.0)"""
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / "tools" / "model_quality_score.py"


def run_tool(targets_text, actual_dict):
    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        targets = td / "指标目标卡.md"
        targets.write_text(targets_text, encoding="utf-8")
        actual = td / "actual.json"
        actual.write_text(json.dumps(actual_dict, ensure_ascii=False), encoding="utf-8")
        out = td / "model_quality_score.json"
        r = subprocess.run(
            [sys.executable, str(TOOL), "--targets", str(targets),
             "--actual", str(actual), "--out", str(out)],
            capture_output=True, text=True)
        result = json.loads(out.read_text(encoding="utf-8")) if out.exists() else None
        return r.returncode, result, r.stdout


TARGETS_MD = """| 子问题 | 指标 | 目标值 | 硬/软 | 验证口径 |
|---|---|---|---|---|
| 问题2 | R2_test | ≥0.90 / ≥0.80 | 硬 / 软 | 10-split 均值 |
| 问题2 | R2_std | <0.05 | 软 | 10-split std |
| 问题3 | 提升幅度 | ≥0.05 | 硬 | 对比基准 |
"""


class ModelQualityTests(unittest.TestCase):
    def test_all_pass(self):
        code, result, out = run_tool(TARGETS_MD, {
            "问题2": {"R2_test": 0.94, "R2_std": 0.02},
            "问题3": {"提升幅度": 0.08}})
        self.assertEqual(code, 0)
        self.assertEqual(result["summary"], "ALL_PASS")

    def test_hard_fail_triggers_exit_2(self):
        code, result, out = run_tool(TARGETS_MD, {
            "问题2": {"R2_test": 0.60, "R2_std": 0.02},
            "问题3": {"提升幅度": 0.08}})
        self.assertEqual(code, 2)
        self.assertEqual(result["summary"], "HARD_FAIL")
        self.assertTrue(any(i["metric"] == "R2_test" for i in result["fail_hard"]))

    def test_soft_fail_triggers_exit_1(self):
        code, result, out = run_tool(TARGETS_MD, {
            "问题2": {"R2_test": 0.94, "R2_std": 0.09},
            "问题3": {"提升幅度": 0.08}})
        self.assertEqual(code, 1)
        self.assertEqual(result["summary"], "SOFT_FAIL")

    def test_missing_metric_rated_missing(self):
        code, result, out = run_tool(TARGETS_MD, {
            "问题2": {"R2_test": 0.94, "R2_std": 0.02}})
        self.assertEqual(code, 2)  # 问题3 硬指标 MISSING 视为不达标
        self.assertTrue(any(i["rating"] == "MISSING" for i in result["fail_hard"]))

    def test_dual_threshold_uses_hard_value(self):
        code, result, out = run_tool(TARGETS_MD, {
            "问题2": {"R2_test": 0.94, "R2_std": 0.02},
            "问题3": {"提升幅度": 0.08}})
        r2 = [i for i in result["items"] if i["metric"] == "R2_test"]
        self.assertEqual(r2[0]["target"], 0.90)  # 硬档取 ≥0.90


if __name__ == "__main__":
    unittest.main()
# 
