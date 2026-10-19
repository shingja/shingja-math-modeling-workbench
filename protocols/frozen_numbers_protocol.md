# Frozen Numbers 协议 v1.0⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


> 作者 [shingja](https://github.com/shingja) · 许可见 [LICENSE](../LICENSE) · 禁止移除署名与版权标识

**吸收自**: zhnnky329/MathModeling-skills (Gate-driven pipeline)
**融合**: 我方已有的 SHA-256 哈希绑定 + L3 自复算

---

## 一、核心原则

**论文中出现的每一个数值，必须可追溯到代码运行的真实输出。**

禁止：
- 手写数值 (硬编码常量除外, 如物理常数)
- 从论文中抄录数值 (交叉验证时除外, 且必须标注来源)
- "合理推测"的数值 (标记为 [UNVERIFIED] 并排除)

## 二、frozen_numbers.json 格式

```json
{
  "project": "T01 板凳龙闹元宵",
  "sha256": "dbd07340...",
  "frozen_at": "2026-07-29T20:00:00",
  "numbers": [
    {
      "id": "Q1_r_head_300s",
      "value": 4.992315,
      "unit": "m",
      "source_file": "results/result1.xlsx",
      "source_location": "Row301 Col[head_x, head_y]",
      "computed_by": "src/main.py solve_q1",
      "frozen": true
    }
  ],
  "modification_log": []
}
```

## 三、冻结与解冻流程

1. **Tide运行完成后** → 自动生成 `frozen_numbers.json`
2. **Gloom启动前** → 读取 `frozen_numbers.json`, 所有数值从此文件提取
3. **修改数值** → 必须:
   a. 重新运行代码
   b. 更新 `frozen_numbers.json`
   c. 在 `modification_log` 中记录修改原因和新的SHA-256
   d. 重新运行 W2 门禁
4. **W2 门禁** → 检查论文中每个数值是否存在于 frozen_numbers 中, 偏差 < 0.1%

## 四、与其他组件的集成

- **SHA-256**: frozen_numbers.json 内容哈希与 result_hash.txt 一致
- **L3 自复算**: 独立运行产生第二个 frozen_numbers, 偏差 < 1%
- **W2 门禁**: 逐项检查论文数值 vs frozen_numbers
- **diff_report**: L1/L2 数值 vs frozen_numbers 数值

## 五、实战案例 (T01)

T01 第一轮论文中 Q2 的 "物理合理性自证" 如果使用 Frozen Numbers 协议, 会立即发现:
- frozen_numbers 中 Q2=441.0s
- 论文声称"物理合理"
- W2 门禁: frozen_numbers 中有但论文未标注来源 → **门禁失败**

这正是 Frozen Numbers 的价值: **数值必须有源**。
