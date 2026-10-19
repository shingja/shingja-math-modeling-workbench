#!/usr/bin/env python3
# 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
"""模型质量评分卡 (M-Loop 核心工具, v4.2.0)

读取Linger的"指标目标卡"与Tide的结果数据, 输出每指标达成度三档评级。

用法:
    python model_quality_score.py --targets <指标目标卡路径或json> \
        --actual <实际指标json> --out <输出json路径>

指标目标卡格式 (json 或从 md 表格解析):
{
  "问题1": [
    {"metric": "R2_test", "target": 0.90, "hard": true, "note": "10-split均值"},
    {"metric": "R2_std",  "target": 0.05, "hard": false}
  ],
  ...
}
实际指标格式:
{
  "问题1": {"R2_test": 0.94, "R2_std": 0.02},
  ...
}
输出: model_quality_score.json
{
  "summary": "ALL_PASS" | "HARD_FAIL" | "SOFT_FAIL",
  "items": [{"problem":"问题1","metric":"R2_test","actual":0.94,"target":0.90,"hard":true,"rating":"PASS"}],
  "fail_hard": [...], "fail_soft": [...]
}
支持从指标目标卡.md 表格解析(格式见协议 §2): | 子问题 | 指标 | 目标值 | 硬/软 | 验证口径 |
"""
import argparse
import json
import re
import sys
from pathlib import Path


TOL = 1e-9


def parse_md_table(text: str):
    """解析协议 §2 格式的指标目标卡.md 表格, 返回 {problem: [metric条目]}"""
    targets = {}
    for line in text.splitlines():
        line = line.strip()
        if not line.startswith("|") or re.match(r"^\|[\s:-]+\|", line):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) < 4 or cells[0] in ("子问题", "问题"):
            continue
        problem, metric, target_s, hard_s = cells[0], cells[1], cells[2], cells[3]
        m = re.search(r"(\d+\.?\d*)", str(target_s))
        if not m:
            continue
        # 支持 "≥0.90 / ≥0.80" 双档: 取硬档; "硬 / 软" 双标: 生成两条
        # 支持方向符: "<0.05" = 越小越好(direction=lt), "≥0.90" = 越大越好(gt)
        direction = "lt" if "<" in str(target_s) else "gt"
        hard_soft = [s for s in re.split(r"[\/、,]", str(hard_s)) if "硬" in s or "软" in s]
        for hs in hard_soft:
            hard = "硬" in hs
            idx = 0 if hard else 1
            vals = re.findall(r"(\d+\.?\d*)", str(target_s))
            if len(vals) <= idx:
                idx = 0
            entry = {"metric": metric, "target": float(vals[idx]), "hard": hard,
                     "direction": direction}
            targets.setdefault(problem, []).append(entry)
    return targets


def load_targets(path: str):
    p = Path(path)
    if p.suffix == ".json":
        return json.loads(p.read_text(encoding="utf-8"))
    text = p.read_text(encoding="utf-8")
    return parse_md_table(text)


def rate(target, actual, direction="gt"):
    if direction == "lt":  # 越小越好
        return actual <= target + TOL
    return actual >= target - TOL  # 越大越好


def score(targets, actual):
    items, fail_hard, fail_soft = [], [], []
    for problem, entries in targets.items():
        for e in entries:
            key = e["metric"]
            val = (actual.get(problem) or {}).get(key)
            rating = "MISSING" if val is None else (
                "PASS" if rate(e["target"], val, e.get("direction", "gt")) else "FAIL")
            item = {"problem": problem, "metric": key, "actual": val,
                    "target": e["target"], "hard": e["hard"], "rating": rating}
            items.append(item)
            if rating in ("FAIL", "MISSING"):
                (fail_hard if e["hard"] else fail_soft).append(item)
    summary = "HARD_FAIL" if fail_hard else ("SOFT_FAIL" if fail_soft else "ALL_PASS")
    return {"summary": summary, "items": items,
            "fail_hard": fail_hard, "fail_soft": fail_soft}


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--targets", required=True, help="指标目标卡 (json 或 md)")
    ap.add_argument("--actual", required=True, help="实际指标 json")
    ap.add_argument("--out", default="model_quality_score.json", help="输出 json")
    a = ap.parse_args()

    targets = load_targets(a.targets)
    actual = json.loads(Path(a.actual).read_text(encoding="utf-8"))
    result = score(targets, actual)
    out = Path(a.out)
    out.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"summary: {result['summary']}")
    for it in result["items"]:
        print(f"  {it['problem']}/{it['metric']}: actual={it['actual']} "
              f"target={it['target']} ({'硬' if it['hard'] else '软'}) -> {it['rating']}")
    if result["fail_hard"]:
        print(f"[HARD_FAIL] {len(result['fail_hard'])} 项不达标 → 触发 M-Loop 回Linger")
        sys.exit(2)
    if result["fail_soft"]:
        print(f"[SOFT_FAIL] {len(result['fail_soft'])} 项软指标不达标 → 先数值卫生修复")
        sys.exit(1)
    print("[ALL_PASS] 全部指标达标")


if __name__ == "__main__":
    main()
